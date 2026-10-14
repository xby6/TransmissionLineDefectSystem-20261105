import io
import json
import tempfile
import zipfile
from pathlib import Path

import numpy as np
from PIL import Image

from algo_support.image_io import float_parameter, int_parameter, iter_input_images, png_bytes
from algo_support.occlusion import process_one_pred
from algo_support.reconstruction import (
    expand_mask_within, fill_avg_soft, nn_cover_fill, shift_cover_fill_by_nn,
    id_to_color_bgr, overlay_bgr, PALETTE_RGB,
)
from algo_support.segmentation import (
    class_statistics, load_model, predict_id_map, write_segmentation_results,
)


def algorithm(zip_path: Path, model_name: str = "deeplabv3_plus.pth",
              corridor_width: int = 5, max_gap_dist: float = 50,
              other_ratio_th: float = 0.35, closing_ksize: int = 11,
              bow: float = 0.35, thickness: int = 3, use_shape_prior: int = 1,
              shape_method: str = "close", shape_close_ksize: int = 31,
              shape_occluder_dilate: int = 9, fill_mode: str = "nn_cover",
              mask_expand: int = 3, overlay_alpha: float = 0.5,
              device: str = "auto") -> bytes:
    """Segmentation -> occlusion geometry -> texture reconstruction -> result ZIP."""
    params = {
        "background_id": 0,
        "corridor_width": int_parameter(corridor_width, "corridor_width", 1, 101),
        "max_gap_dist": float_parameter(max_gap_dist, "max_gap_dist", 1, 2000),
        "other_ratio_th": float_parameter(other_ratio_th, "other_ratio_th", 0, 1),
        "closing_ksize": int_parameter(closing_ksize, "closing_ksize", 1, 101),
        "bow": float_parameter(bow, "bow", 0, 1),
        "thickness": int_parameter(thickness, "thickness", 1, 31),
        "use_shape_prior": bool(int_parameter(use_shape_prior, "use_shape_prior", 0, 1)),
        "shape_method": shape_method,
        "shape_close_ksize": int_parameter(shape_close_ksize, "shape_close_ksize", 1, 151),
        "shape_occluder_dilate": int_parameter(shape_occluder_dilate, "shape_occluder_dilate", 1, 101),
    }
    if shape_method not in ("close", "hull"):
        raise ValueError("shape_method 只支持 close 或 hull")
    if fill_mode not in ("nn_cover", "shift", "avg_soft"):
        raise ValueError("fill_mode 只支持 nn_cover、shift 或 avg_soft")
    expansion = int_parameter(mask_expand, "mask_expand", 0, 31)
    alpha = float_parameter(overlay_alpha, "overlay_alpha", 0, 1)
    model, target, metadata = load_model(model_name, device)
    if not metadata["class_names_verified"] or metadata["class_names"][0] not in ("background", "背景"):
        raise ValueError("遮挡补全需要确认类别 0 为背景；该模型请先使用 deeplabv3 输出类别 ID，或补充训练类别表")
    # Keep the seed from the supplied config for reproducible geometry sampling.
    np.random.seed(0)
    buffer = io.BytesIO()
    with tempfile.TemporaryDirectory(prefix="line_occlusion_") as temp_dir:
        with zipfile.ZipFile(buffer, "w", zipfile.ZIP_DEFLATED) as archive:
            for index, (source_name, prefix, image) in enumerate(iter_input_images(zip_path), 1):
                prediction = predict_id_map(model, target, image, metadata, restore_method="opencv")
                palette = [PALETTE_RGB[i] for i in range(metadata["num_classes"])]
                write_segmentation_results(archive, prefix, source_name, image, prediction, metadata, alpha,
                                           palette=palette, overlay_foreground=True)
                post_dir = Path(temp_dir) / f"image-{index:03d}"
                process_one_pred(pred=prediction.astype(np.int32), out_dir=post_dir, **params)
                with Image.open(post_dir / "filled_idmap.png") as mask:
                    filled = np.asarray(mask).copy()
                reconstructed = np.asarray(image)[:, :, ::-1].copy()
                for class_id in range(1, metadata["num_classes"]):
                    visible = prediction == class_id
                    filled_class = filled == class_id
                    added = filled_class & ~visible
                    if not added.any():
                        continue
                    expanded = expand_mask_within(added, within_bool=filled_class, expand=expansion)
                    if fill_mode == "avg_soft":
                        reconstructed = fill_avg_soft(reconstructed, visible, expanded, feather=11,
                                                      fallback_color=(128, 128, 128))
                    elif fill_mode == "shift":
                        reconstructed = shift_cover_fill_by_nn(reconstructed, visible, expanded,
                                                               roi_pad=40, feather=0,
                                                               fallback_color=(128, 128, 128))
                    else:
                        reconstructed = nn_cover_fill(reconstructed, visible, expanded, feather=0)
                color_bgr = id_to_color_bgr(filled, metadata["num_classes"])
                color = color_bgr[:, :, ::-1]
                original_bgr = np.asarray(image)[:, :, ::-1]
                overlay = overlay_bgr(original_bgr, color_bgr, alpha)[:, :, ::-1]
                added_mask = filled != prediction
                archive.writestr(prefix + "_filled_id.png", png_bytes(filled))
                archive.writestr(prefix + "_filled_color.png", png_bytes(color))
                archive.writestr(prefix + "_filled_overlay.png", png_bytes(overlay))
                archive.writestr(prefix + "_added_mask.png", png_bytes(added_mask.astype(np.uint8) * 255))
                archive.writestr(prefix + "_reconstruct.png", png_bytes(reconstructed[:, :, ::-1]))
                summary = dict(metadata, source_name=source_name, image_size=list(image.size),
                               geometry_parameters=params, fill_mode=fill_mode, mask_expand=expansion,
                               changed_mask_pixels=int(added_mask.sum()),
                               classes_after_fill=class_statistics(filled, metadata["class_names"]),
                               note="遮挡补全属于算法推断，不代表原始巡检图像的真实可见内容。")
                archive.writestr(prefix + "_occlusion.json", json.dumps(summary, ensure_ascii=False, indent=2))
    return buffer.getvalue()
