"""Occlusion geometry from the supplied skeleton archive; CLI replaced by system adapters."""
from pathlib import Path

import numpy as np
import cv2

from .image_io import save_id_map_png


# =========================================================
# 基础：连通域 / bbox
# =========================================================
def connected_components(binary_mask: np.ndarray):
    num, lab = cv2.connectedComponents(binary_mask.astype(np.uint8), connectivity=8)
    comps = []
    for k in range(1, num):
        comps.append(lab == k)
    return comps

def bbox(mask: np.ndarray):
    ys, xs = np.where(mask)
    return int(ys.min()), int(xs.min()), int(ys.max()), int(xs.max())

def bbox_dist2(b1, b2):
    y1, x1, y2, x2 = b1
    yy1, xx1, yy2, xx2 = b2
    dy = max(0, max(y1 - yy2, yy1 - y2))
    dx = max(0, max(x1 - xx2, xx1 - x2))
    return dx * dx + dy * dy


# =========================================================
# 最近点对 + 走廊
# =========================================================
def nearest_points_dt(mask_a: np.ndarray, mask_b: np.ndarray):
    inv_b = (~mask_b).astype(np.uint8)
    dist = cv2.distanceTransform(inv_b, distanceType=cv2.DIST_L2, maskSize=3)

    ys, xs = np.where(mask_a)
    if len(ys) == 0:
        return None, None

    dvals = dist[ys, xs]
    idx = int(np.argmin(dvals))
    ya, xa = int(ys[idx]), int(xs[idx])

    bys, bxs = np.where(mask_b)
    if len(bys) == 0:
        return (ya, xa), None

    if len(bys) > 5000:
        sel = np.random.choice(len(bys), 5000, replace=False)
        bys, bxs = bys[sel], bxs[sel]

    d2 = (bys - ya) ** 2 + (bxs - xa) ** 2
    j = int(np.argmin(d2))
    yb, xb = int(bys[j]), int(bxs[j])

    return (ya, xa), (yb, xb)

def draw_corridor(shape_hw, p1, p2, corridor_width=11):
    h, w = shape_hw
    line = np.zeros((h, w), np.uint8)
    cv2.line(line, (int(p1[1]), int(p1[0])), (int(p2[1]), int(p2[0])), 1, thickness=1)

    if corridor_width > 1:
        k = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (corridor_width, corridor_width))
        line = cv2.dilate(line, k, iterations=1)

    return line.astype(bool)


# =========================================================
# 遮挡判定：走廊内其它id占比 + 邻接
# =========================================================
def occlusion_check_and_gap(pred: np.ndarray,
                            comp_i: np.ndarray,
                            comp_j: np.ndarray,
                            this_id: int,
                            background_id: int,
                            corridor_width: int,
                            max_gap_dist: float,
                            other_ratio_th: float):
    """
    返回:
      is_occluded(bool),
      gap_mask(bool): corridor 内其它id像素（非0非本类）
      corridor(bool)
    """
    p1, p2 = nearest_points_dt(comp_i, comp_j)
    if p1 is None or p2 is None:
        return False, np.zeros_like(comp_i, dtype=bool), np.zeros_like(comp_i, dtype=bool)

    dy = p1[0] - p2[0]
    dx = p1[1] - p2[1]
    dist = float(np.sqrt(dx * dx + dy * dy))
    if dist > max_gap_dist:
        return False, np.zeros_like(comp_i, dtype=bool), np.zeros_like(comp_i, dtype=bool)

    corridor = draw_corridor(pred.shape, p1, p2, corridor_width=corridor_width)
    vals = pred[corridor]
    if vals.size == 0:
        return False, np.zeros_like(comp_i, dtype=bool), corridor

    other_fg = (vals != this_id) & (vals != background_id)
    other_ratio = float(other_fg.mean())
    if other_ratio < other_ratio_th:
        return False, np.zeros_like(comp_i, dtype=bool), corridor

    gap = corridor & (pred != this_id) & (pred != background_id)

    # 邻接：gap 膨胀后必须同时触碰两侧片段
    gap_u8 = gap.astype(np.uint8)
    k = cv2.getStructuringElement(cv2.MORPH_RECT, (3, 3))
    gap_d = cv2.dilate(gap_u8, k, iterations=2).astype(bool)

    if not ((gap_d & comp_i).any() and (gap_d & comp_j).any()):
        return False, np.zeros_like(comp_i, dtype=bool), corridor

    return True, gap, corridor


# =========================================================
# 弧线桥接（用于“断裂成多块”的情况）
# =========================================================
def boundary_points(mask_bool: np.ndarray):
    m = (mask_bool.astype(np.uint8) * 255)
    cnts, _ = cv2.findContours(m, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
    if not cnts:
        return np.zeros((0, 2), dtype=np.int32)
    c = max(cnts, key=cv2.contourArea)
    pts = c[:, 0, :]  # (N,2) x,y
    pts = np.stack([pts[:, 1], pts[:, 0]], axis=1)  # -> y,x
    return pts.astype(np.int32)

def pick_endpoint_near_corridor(comp_mask: np.ndarray, corridor_mask: np.ndarray):
    pts = boundary_points(comp_mask)
    if pts.shape[0] == 0:
        return None

    cy, cx = np.where(corridor_mask)
    if len(cy) == 0:
        return None
    yc = int(np.mean(cy))
    xc = int(np.mean(cx))

    d2 = (pts[:, 0] - yc) ** 2 + (pts[:, 1] - xc) ** 2
    idx = int(np.argmin(d2))
    return (int(pts[idx, 0]), int(pts[idx, 1]))

def bezier_curve(p0, p1, p2, n=140):
    t = np.linspace(0, 1, n, dtype=np.float32)[:, None]
    p0 = np.array(p0, np.float32)[None, :]
    p1 = np.array(p1, np.float32)[None, :]
    p2 = np.array(p2, np.float32)[None, :]
    pts = (1 - t) ** 2 * p0 + 2 * (1 - t) * t * p1 + t ** 2 * p2
    return pts

def arc_bridge_mask(shape_hw, pA, pB, corridor_mask, bow=0.35, thickness=3):
    h, w = shape_hw
    y1, x1 = pA
    y2, x2 = pB

    my, mx = (y1 + y2) / 2.0, (x1 + x2) / 2.0
    dy, dx = (y2 - y1), (x2 - x1)
    L = np.sqrt(dy * dy + dx * dx) + 1e-6

    ny, nx = -dx / L, dy / L
    cy = my + ny * (bow * L)
    cx = mx + nx * (bow * L)

    pts = bezier_curve((y1, x1), (cy, cx), (y2, x2), n=160)
    pts_int = np.round(pts).astype(np.int32)
    pts_int[:, 0] = np.clip(pts_int[:, 0], 0, h - 1)
    pts_int[:, 1] = np.clip(pts_int[:, 1], 0, w - 1)

    line = np.zeros((h, w), np.uint8)
    for i in range(len(pts_int) - 1):
        y0, x0 = pts_int[i]
        y1_, x1_ = pts_int[i + 1]
        cv2.line(line, (int(x0), int(y0)), (int(x1_), int(y1_)), 255, thickness=thickness)

    return (line > 0) & corridor_mask


# =========================================================
# 形状先验补全（用于“没有分裂但边缘被侵蚀”的情况）
#   - expected: 目标物如果没被挡的大致形状
#   - missing = expected - visible
#   - occluder = 非背景、非本类（任何遮挡物）
#   - 只在 occluder 附近补：missing & dilate(occluder)
# =========================================================
def convex_hull_mask(bin_mask: np.ndarray) -> np.ndarray:
    m = (bin_mask.astype(np.uint8) * 255)
    cnts, _ = cv2.findContours(m, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if not cnts:
        return np.zeros_like(bin_mask, dtype=bool)
    c = max(cnts, key=cv2.contourArea)
    hull = cv2.convexHull(c)
    out = np.zeros_like(m)
    cv2.drawContours(out, [hull], -1, 255, -1)
    return out > 0

def fill_occlusion_by_shape_prior_any(pred: np.ndarray,
                                      target_id: int,
                                      background_id: int = 0,
                                      method: str = "close",     # "close" or "hull"
                                      close_ksize: int = 31,
                                      occluder_dilate: int = 9):
    visible = (pred == target_id)
    occluder = (pred != background_id) & (pred != target_id)

    if method == "close":
        k = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (close_ksize, close_ksize))
        expected = cv2.morphologyEx((visible.astype(np.uint8) * 255),
                                    cv2.MORPH_CLOSE, k, iterations=1) > 0
    elif method == "hull":
        expected = convex_hull_mask(visible)
    else:
        raise ValueError("method must be 'close' or 'hull'")

    missing = expected & (~visible)

    k2 = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (occluder_dilate, occluder_dilate))
    occ_band = cv2.dilate((occluder.astype(np.uint8) * 255), k2, iterations=1) > 0

    occluded_fill = missing & occ_band
    filled = visible | occluded_fill
    return filled, occluded_fill, expected


# =========================================================
# 局部补全：让 seed 成面（膨胀+闭运算）
# =========================================================
def local_fill_from_seed(visible_mask: np.ndarray, seed_mask: np.ndarray, closing_ksize=11):
    if not seed_mask.any():
        return visible_mask.copy()

    seed_u8 = seed_mask.astype(np.uint8) * 255

    # 先膨胀
    k1 = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (7, 7))
    seed_u8 = cv2.dilate(seed_u8, k1, iterations=1)

    # 再闭运算
    k2 = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (closing_ksize, closing_ksize))
    closed = cv2.morphologyEx(seed_u8, cv2.MORPH_CLOSE, k2, iterations=1) > 0

    return visible_mask | closed


# =========================================================
# 主处理
# =========================================================
def process_one_pred(pred: np.ndarray,
                     out_dir: Path,
                     background_id: int,
                     corridor_width: int,
                     max_gap_dist: float,
                     other_ratio_th: float,
                     closing_ksize: int,
                     bow: float,
                     thickness: int,
                     use_shape_prior: bool,
                     shape_method: str,
                     shape_close_ksize: int,
                     shape_occluder_dilate: int):

    h, w = pred.shape
    unique_ids = np.unique(pred)
    unique_ids = [int(x) for x in unique_ids.tolist() if int(x) != background_id]

    filled_idmap = pred.copy()
    occ_summary = np.zeros((h, w), dtype=bool)

    out_dir.mkdir(parents=True, exist_ok=True)

    for k in unique_ids:
        visible = (pred == k)
        comps = connected_components(visible)

        # 可见区域
        save_id_map_png(str(out_dir / f"id_{k}_visible.png"), (visible.astype(np.uint8) * 255))

        gap_mask = np.zeros_like(visible, dtype=bool)
        bridge_mask = np.zeros_like(visible, dtype=bool)

        # ---- 情况1：断裂成多块，用走廊遮挡判定 + 弧线桥接 ----
        if len(comps) > 1:
            bxs = [bbox(c) for c in comps]
            for i in range(len(comps)):
                for j in range(i + 1, len(comps)):
                    if bbox_dist2(bxs[i], bxs[j]) > (max_gap_dist * max_gap_dist):
                        continue

                    is_occ, gap, corridor = occlusion_check_and_gap(
                        pred=pred,
                        comp_i=comps[i],
                        comp_j=comps[j],
                        this_id=k,
                        background_id=background_id,
                        corridor_width=corridor_width,
                        max_gap_dist=max_gap_dist,
                        other_ratio_th=other_ratio_th,
                    )

                    if is_occ:
                        gap_mask |= gap

                        pA = pick_endpoint_near_corridor(comps[i], corridor)
                        pB = pick_endpoint_near_corridor(comps[j], corridor)
                        if pA is not None and pB is not None:
                            bridge = arc_bridge_mask(
                                shape_hw=pred.shape,
                                pA=pA, pB=pB,
                                corridor_mask=corridor,
                                bow=bow,
                                thickness=thickness
                            )
                            bridge_mask |= bridge

        # 先用 gap+bridge 补一次（对“分裂”很有效）
        seed = gap_mask | bridge_mask
        filled = local_fill_from_seed(visible, seed, closing_ksize=closing_ksize)

        # ---- 情况2：不分裂但被侵蚀，用形状先验补（对你那张绝缘子特别有效）----
        expected_shape = np.zeros_like(visible, dtype=bool)
        occ_fill_shape = np.zeros_like(visible, dtype=bool)

        if use_shape_prior:
            filled_shape, occ_fill_shape, expected_shape = fill_occlusion_by_shape_prior_any(
                pred=pred,
                target_id=k,
                background_id=background_id,
                method=shape_method,
                close_ksize=shape_close_ksize,
                occluder_dilate=shape_occluder_dilate
            )
            # 只合并新增部分（保证不破坏原可见）
            filled = filled | (filled_shape & (~visible))

        # 输出调试/结果
        save_id_map_png(str(out_dir / f"id_{k}_occlusion_gap.png"), (gap_mask.astype(np.uint8) * 255))
        save_id_map_png(str(out_dir / f"id_{k}_bridge.png"), (bridge_mask.astype(np.uint8) * 255))
        save_id_map_png(str(out_dir / f"id_{k}_expected.png"), (expected_shape.astype(np.uint8) * 255))
        save_id_map_png(str(out_dir / f"id_{k}_occfill_shape.png"), (occ_fill_shape.astype(np.uint8) * 255))
        save_id_map_png(str(out_dir / f"id_{k}_filled.png"), (filled.astype(np.uint8) * 255))

        # 总览
        occ_summary |= (gap_mask | bridge_mask | occ_fill_shape)

        # 合成总 id 图：把新增像素写成 k（会覆盖新增区域原来的遮挡物 id）
        added = filled & (~visible)
        filled_idmap[added] = k

    save_id_map_png(str(out_dir / "filled_idmap.png"), filled_idmap.astype(np.int32))
    save_id_map_png(str(out_dir / "occlusion_summary.png"), (occ_summary.astype(np.uint8) * 255))
