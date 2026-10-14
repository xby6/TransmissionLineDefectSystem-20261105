"""Strict checkpoint loading and archive-compatible DeepLab image inference."""
import io
import json
import zipfile
from pathlib import Path

import cv2
import numpy as np
import torch
import yaml
from PIL import Image

from nets.deeplabv3_plus import DeepLab
from .image_io import float_parameter, iter_input_images, png_bytes


SERVER_ROOT = Path(__file__).resolve().parents[1]
CLASS_NAMES = ["background", "绝缘子", "杆塔", "导线", "杆塔脚钉", "销钉", "悬垂线夹", "防震锤"]
PALETTE = np.array([
    [0, 0, 0], [128, 0, 0], [0, 128, 0], [128, 128, 0],
    [0, 0, 128], [128, 0, 128], [0, 128, 128], [128, 128, 128],
], dtype=np.uint8)


def load_model(model_name, device="auto"):
    registry = yaml.safe_load((SERVER_ROOT / "model_config.yaml").read_text(encoding="utf-8"))
    info = registry.get("models", {}).get(model_name)
    if not info or info.get("task") != "segmentation":
        raise ValueError(f"请选择已登记的语义分割模型：{model_name}")
    model_path = (SERVER_ROOT / info["file"]).resolve()
    if not model_path.is_relative_to((SERVER_ROOT / "model").resolve()) or not model_path.is_file():
        raise ValueError(f"语义分割模型文件不存在或路径无效：{model_name}")
    if device not in ("auto", "cpu", "cuda"):
        raise ValueError("device 只支持 auto、cpu 或 cuda")
    if device == "cuda" and not torch.cuda.is_available():
        raise ValueError("当前运行环境没有可用的 CUDA，请使用 auto 或 cpu")
    target = torch.device("cuda" if device == "auto" and torch.cuda.is_available() else ("cpu" if device == "auto" else device))
    if info.get("checkpoint_format") == "full_module":
        # Compatibility with the pre-existing, trusted full-model checkpoint.
        model = torch.load(model_path, map_location="cpu", weights_only=False)
        if not isinstance(model, torch.nn.Module):
            raise ValueError("登记的完整模型文件不包含 PyTorch 模型")
        num_classes = int(info["num_classes"])
        backbone = info.get("backbone", "legacy")
    else:
        state = torch.load(model_path, map_location="cpu", weights_only=True)
        if not isinstance(state, dict):
            raise ValueError("权重文件不是 state_dict")
        for wrapper in ("state_dict", "model_state_dict"):
            if wrapper in state:
                state = state[wrapper]
                break
        if not isinstance(state, dict) or not state:
            raise ValueError("权重文件没有有效模型参数")
        state = {key.removeprefix("module."): value for key, value in state.items()}
        head = state.get("cls_conv.weight")
        if not isinstance(head, torch.Tensor) or head.ndim != 4:
            raise ValueError("不支持该权重的分类头结构")
        num_classes = int(head.shape[0])
        if any(key.startswith("backbone.features.") for key in state):
            backbone = "mobilenet"
        elif "backbone.conv1.weight" in state:
            backbone = "xception"
        else:
            raise ValueError("不支持该权重的主干网络")
        if info.get("num_classes") != num_classes or info.get("backbone") != backbone:
            raise ValueError("模型登记信息与实际权重的类别数或主干网络不一致")
        model = DeepLab(num_classes=num_classes, backbone=backbone, pretrained=False,
                        downsample_factor=int(info.get("downsample_factor", 16)))
        # Never drop unmatched parameters or run with an untrained random head.
        model.load_state_dict(state, strict=True)
    names = info.get("class_names", [])
    if names and (len(names) != num_classes or any(not isinstance(name, str) for name in names)):
        raise ValueError("类别名称表与模型类别数不一致")
    if not names:
        names = [f"类别{i}" for i in range(num_classes)]
    metadata = {
        "model_name": model_name,
        "backbone": backbone,
        "num_classes": num_classes,
        "class_names": names,
        "class_names_verified": bool(info.get("class_names_verified", False)),
        "input_shape": info.get("input_shape", [512, 512]),
        "device": str(target),
    }
    model.to(target).eval()
    return model, target, metadata


def predict_id_map(model, device, image, metadata, restore_method="pil"):
    # Same resize, normalization, channel ordering and argmax as supplied predict.py.
    resized = image.resize(tuple(metadata["input_shape"]), Image.Resampling.BILINEAR)
    array = np.asarray(resized, dtype=np.float32) / 255.0
    tensor = torch.from_numpy(np.transpose(array, (2, 0, 1)).copy()).unsqueeze(0).to(device)
    with torch.inference_mode():
        logits = model(tensor)
        if isinstance(logits, dict):
            logits = logits.get("out")
        if not isinstance(logits, torch.Tensor) or logits.ndim != 4 or logits.shape[1] != metadata["num_classes"]:
            raise ValueError("模型没有返回与类别表一致的语义分割 logits")
        if not torch.isfinite(logits).all():
            raise ValueError("模型推理结果包含非有限数值")
        small = logits.argmax(dim=1).squeeze(0).cpu().numpy().astype(np.uint8)
    if restore_method == "opencv":
        # The skeleton's infer.py uses OpenCV's nearest-neighbor coordinates.
        return cv2.resize(small, image.size, interpolation=cv2.INTER_NEAREST)
    return np.asarray(Image.fromarray(small).resize(image.size, Image.Resampling.NEAREST)).copy()


def colorize(id_map, palette=None):
    colors = PALETTE if palette is None else np.asarray(palette, dtype=np.uint8)
    if id_map.size and (id_map.min() < 0 or id_map.max() >= len(colors)):
        raise ValueError("输出掩膜超出调色板类别范围")
    return colors[id_map]


def class_statistics(id_map, names):
    counts = np.bincount(id_map.ravel(), minlength=len(names))
    total = int(id_map.size)
    return [{"class_id": i, "class_name": name, "pixels": int(counts[i]),
             "area_ratio_percent": round(100 * int(counts[i]) / total, 6)}
            for i, name in enumerate(names)]


def write_segmentation_results(archive, prefix, source_name, image, id_map, metadata, alpha,
                               palette=None, overlay_foreground=False):
    color = colorize(id_map, palette)
    if overlay_foreground:
        from .reconstruction import overlay_bgr
        # The original operation is component-wise and works in RGB too.
        fused = overlay_bgr(np.asarray(image), color, alpha)
    else:
        fused = np.asarray(Image.blend(image, Image.fromarray(color), alpha))
    archive.writestr(prefix + "_pred.png", png_bytes(id_map))
    archive.writestr(prefix + "_seg.png", png_bytes(color))
    archive.writestr(prefix + "_overlay.png", png_bytes(fused))
    statistics = class_statistics(id_map, metadata["class_names"])
    result = dict(metadata, source_name=source_name, image_size=list(image.size), classes=statistics)
    archive.writestr(prefix + "_statistics.json", json.dumps(result, ensure_ascii=False, indent=2))
    lines = ["Detected Classes and Area Ratio:"]
    for item in statistics:
        if (item["class_id"] != 0 or not metadata["class_names_verified"]) and item["pixels"]:
            lines.append(f'{item["class_name"]}: {item["area_ratio_percent"]:.2f}%')
    if len(lines) == 1:
        lines.append("No foreground class detected.")
    if not metadata["class_names_verified"]:
        lines.append("类别名称尚未提供，当前仅输出类别 ID，不代表已确认的部件名称。")
    archive.writestr(prefix + "_statistics.txt", "\n".join(lines) + "\n")
    return result


def run_segmentation(zip_path, model_name, overlay_alpha=0.5, device="auto"):
    alpha = float_parameter(overlay_alpha, "overlay_alpha", 0, 1)
    model, target, metadata = load_model(model_name, device)
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, "w", zipfile.ZIP_DEFLATED) as archive:
        for source_name, prefix, image in iter_input_images(zip_path):
            prediction = predict_id_map(model, target, image, metadata)
            write_segmentation_results(archive, prefix, source_name, image, prediction, metadata, alpha)
    return buffer.getvalue()
