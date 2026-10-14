"""Texture reconstruction kernels from the supplied skeleton archive, without CLI or fixed paths."""
import numpy as np
import cv2

PALETTE_RGB = {
    0: [0, 0, 0],         # 背景 - 黑色
    1: [255, 0, 0],       # 导线 - 红色
    2: [0, 255, 0],       # 绝缘子 - 绿色
    3: [0, 0, 255],       # 悬垂线夹 - 蓝色
    4: [255, 255, 0],     # 防震锤 - 黄色
    5: [255, 0, 255],     # 杆塔 - 紫色
    6: [0, 255, 255],     # 杆塔脚钉 - 青色
    7: [128, 0, 128],     # 销钉 - 深紫色
}


def id_to_color_bgr(idmap: np.ndarray, num_classes: int) -> np.ndarray:
    h, w = idmap.shape
    out = np.zeros((h, w, 3), dtype=np.uint8)
    for k in range(num_classes):
        rgb = PALETTE_RGB.get(k, [0, 0, 0])
        out[idmap == k] = [rgb[2], rgb[1], rgb[0]]
    return out

def overlay_bgr(img_bgr: np.ndarray, mask_bgr: np.ndarray, alpha: float) -> np.ndarray:
    non_bg = (mask_bgr.sum(axis=2) > 0)
    out = img_bgr.copy().astype(np.float32)
    m = mask_bgr.astype(np.float32)
    out[non_bg] = out[non_bg] * (1 - alpha) + m[non_bg] * alpha
    return np.clip(out, 0, 255).astype(np.uint8)

def bbox_from_mask(mask_bool: np.ndarray, pad: int):
    ys, xs = np.where(mask_bool)
    if len(ys) == 0:
        return None
    h, w = mask_bool.shape
    y0 = max(int(ys.min()) - pad, 0)
    y1 = min(int(ys.max()) + pad + 1, h)
    x0 = max(int(xs.min()) - pad, 0)
    x1 = min(int(xs.max()) + pad + 1, w)
    return y0, y1, x0, x1

def mean_color_bgr(img_bgr: np.ndarray, mask_bool: np.ndarray):
    ys, xs = np.where(mask_bool)
    if len(ys) == 0:
        return None
    pix = img_bgr[ys, xs].astype(np.float32)
    return np.clip(pix.mean(axis=0), 0, 255).astype(np.uint8)

def feather_alpha(mask_bool: np.ndarray, feather: int):
    m = (mask_bool.astype(np.uint8) * 255)
    if feather <= 0:
        return (m > 0).astype(np.float32)
    ksz = feather * 2 + 1
    blur = cv2.GaussianBlur(m.astype(np.float32), (ksz, ksz), 0) / 255.0
    blur = blur * (m > 0).astype(np.float32)
    return np.clip(blur, 0.0, 1.0)

def expand_mask_within(mask_bool: np.ndarray, within_bool: np.ndarray, expand: int):
    """把 mask 扩边，但限制在 within_bool 内（避免影响其它ID）"""
    if expand <= 0:
        return mask_bool
    k = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (expand*2+1, expand*2+1))
    dil = cv2.dilate(mask_bool.astype(np.uint8)*255, k, iterations=1) > 0
    return dil & within_bool

def fill_avg_soft(img_bgr: np.ndarray, visible_k: np.ndarray, added_k: np.ndarray,
                  feather: int, fallback_color=(128, 128, 128)):
    if not added_k.any():
        return img_bgr
    out = img_bgr.copy()
    avg = mean_color_bgr(out, visible_k)
    if avg is None:
        avg = np.array(fallback_color, dtype=np.uint8)

    fill_img = out.copy()
    fill_img[added_k] = avg

    a = feather_alpha(added_k, feather=feather)
    a3 = np.repeat(a[:, :, None], 3, axis=2)

    out_f = out.astype(np.float32)
    fill_f = fill_img.astype(np.float32)
    mixed = out_f * (1.0 - a3) + fill_f * a3
    out[added_k] = np.clip(mixed, 0, 255).astype(np.uint8)[added_k]
    return out

def nn_cover_fill(img_bgr: np.ndarray, visible_k: np.ndarray, added_k: np.ndarray, feather: int = 0):
    """
    关键：用该ID“附近可见像素”覆盖新增区域
    对每个 added 像素 x，取最近的 visible 像素 n(x) 的颜色 I(n(x)) 覆盖。
    feather=0 -> 硬覆盖（最不留轮廓）
    """
    if not added_k.any() or visible_k.sum() < 10:
        return img_bgr

    out = img_bgr.copy()

    dt_input = (~visible_k).astype(np.uint8) * 255  # visible=0
    _, labels = cv2.distanceTransformWithLabels(
        dt_input, distanceType=cv2.DIST_L2, maskSize=3, labelType=cv2.DIST_LABEL_PIXEL
    )
    labels = labels.astype(np.int32)

    vy, vx = np.where(visible_k)
    vis_labels = labels[vy, vx]
    max_lab = int(vis_labels.max())
    map_y = np.full((max_lab + 1,), -1, dtype=np.int32)
    map_x = np.full((max_lab + 1,), -1, dtype=np.int32)

    for y, x, lab in zip(vy, vx, vis_labels):
        if lab >= 0 and map_y[lab] == -1:
            map_y[lab] = int(y)
            map_x[lab] = int(x)

    ay, ax = np.where(added_k)
    labs = labels[ay, ax]

    fill = out.copy()
    ok = 0
    for y, x, lab in zip(ay, ax, labs):
        if 0 <= lab < map_y.shape[0]:
            ny, nx = map_y[lab], map_x[lab]
            if ny >= 0:
                fill[y, x] = out[ny, nx]
                ok += 1
    if ok == 0:
        return img_bgr

    if feather > 0:
        a = feather_alpha(added_k, feather=feather)
        a3 = np.repeat(a[:, :, None], 3, axis=2)
        out_f = out.astype(np.float32)
        fill_f = fill.astype(np.float32)
        mixed = out_f * (1.0 - a3) + fill_f * a3
        out[added_k] = np.clip(mixed, 0, 255).astype(np.uint8)[added_k]
    else:
        out[added_k] = fill[added_k]
    return out

def shift_cover_fill_by_nn(img_bgr: np.ndarray,
                           visible_k: np.ndarray,
                           added_k: np.ndarray,
                           roi_pad: int = 40,
                           feather: int = 0,
                           fallback_color=(128, 128, 128)):
    """
    用 added_k 到 visible_k 的最近位移(dx,dy)做平移覆盖，只改 added_k。
    feather=0 -> 硬覆盖（更不留轮廓）
    """
    if not added_k.any():
        return img_bgr
    if visible_k.sum() < 30:
        return fill_avg_soft(img_bgr, visible_k, added_k, feather=max(feather, 5), fallback_color=fallback_color)

    bb = bbox_from_mask(added_k, pad=roi_pad)
    if bb is None:
        return img_bgr
    y0, y1, x0, x1 = bb

    roi = img_bgr[y0:y1, x0:x1].copy()
    vis = visible_k[y0:y1, x0:x1].copy()
    add = added_k[y0:y1, x0:x1].copy()

    if vis.sum() < 10:
        return fill_avg_soft(img_bgr, visible_k, added_k, feather=max(feather, 5), fallback_color=fallback_color)

    dt_input = (~vis).astype(np.uint8) * 255
    _, labels = cv2.distanceTransformWithLabels(
        dt_input, distanceType=cv2.DIST_L2, maskSize=3, labelType=cv2.DIST_LABEL_PIXEL
    )
    labels = labels.astype(np.int32)

    vy, vx = np.where(vis)
    vis_labels = labels[vy, vx]
    max_lab = int(vis_labels.max())
    map_y = np.full((max_lab + 1,), -1, dtype=np.int32)
    map_x = np.full((max_lab + 1,), -1, dtype=np.int32)
    for y, x, lab in zip(vy, vx, vis_labels):
        if lab >= 0 and map_y[lab] == -1:
            map_y[lab] = int(y)
            map_x[lab] = int(x)

    ay, ax = np.where(add)
    if len(ay) == 0:
        return img_bgr
    labs = labels[ay, ax]

    dxs, dys = [], []
    for y, x, lab in zip(ay, ax, labs):
        if 0 <= lab < map_y.shape[0]:
            ny, nx = map_y[lab], map_x[lab]
            if ny >= 0:
                dxs.append(int(x - nx))
                dys.append(int(y - ny))

    if len(dxs) < 10:
        return fill_avg_soft(img_bgr, visible_k, added_k, feather=max(feather, 5), fallback_color=fallback_color)

    dx = int(np.median(np.array(dxs)))
    dy = int(np.median(np.array(dys)))
    if dx == 0 and dy == 0:
        return fill_avg_soft(img_bgr, visible_k, added_k, feather=max(feather, 5), fallback_color=fallback_color)

    M = np.float32([[1, 0, dx], [0, 1, dy]])
    src = cv2.warpAffine(
        roi, M, (roi.shape[1], roi.shape[0]),
        flags=cv2.INTER_LINEAR,
        borderMode=cv2.BORDER_REFLECT
    )

    out_roi = roi.copy()
    if feather > 0:
        a = feather_alpha(add, feather=feather)
        a3 = np.repeat(a[:, :, None], 3, axis=2)
        mix = out_roi.astype(np.float32) * (1.0 - a3) + src.astype(np.float32) * a3
        out_roi[add] = np.clip(mix, 0, 255).astype(np.uint8)[add]
    else:
        out_roi[add] = src[add]

    out = img_bgr.copy()
    out[y0:y1, x0:x1] = out_roi
    return out
