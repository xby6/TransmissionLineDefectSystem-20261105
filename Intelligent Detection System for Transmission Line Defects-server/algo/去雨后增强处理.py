import io
from pathlib import Path, PurePosixPath
import zipfile
import cv2
import numpy as np


def detect_rain_streaks(img, strength=0.3):
    """Locate short, bright near-vertical streaks instead of sharpening them."""
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    background = cv2.morphologyEx(gray, cv2.MORPH_OPEN, np.ones((1, 9), np.uint8))
    residual = cv2.subtract(gray, background)
    candidate = (residual > max(5.0, 12.0 - 10.0 * strength)).astype(np.uint8) * 255
    directional = np.zeros_like(candidate)
    for offset in (-2, -1, 0, 1, 2):
        kernel = np.zeros((9, 5), np.uint8)
        cv2.line(kernel, (2 - offset, 0), (2 + offset, 8), 1, 1)
        directional |= cv2.morphologyEx(candidate, cv2.MORPH_OPEN, kernel)

    count, labels, stats, _ = cv2.connectedComponentsWithStats(directional, connectivity=8)
    keep = np.zeros(count, np.uint8)
    # Reject broad equipment boundaries and long continuous lines. Unmasked pixels
    # remain unchanged; inpainting is restricted to the candidate streaks.
    for label in range(1, count):
        _, _, width, height, area = stats[label]
        if 7 <= height <= min(250, img.shape[0] * 0.55) and width <= 12 and height >= 2 * width and area >= 7:
            keep[label] = 255
    return cv2.dilate(keep[labels], np.ones((1, 3), np.uint8))


def adaptive_rain_removal(img, strength=0.3):
    strength = float(strength)
    if not np.isfinite(strength) or not 0 <= strength <= 1:
        raise ValueError('strength 必须是 0～1 之间的有限数值')
    if strength == 0:
        return img.copy()
    mask = detect_rain_streaks(img, strength)
    if not np.any(mask):
        return img.copy()
    restored = cv2.inpaint(img, mask, 3, cv2.INPAINT_TELEA)
    amount = min(1.0, strength / 0.3)
    return cv2.addWeighted(restored, amount, img, 1.0 - amount, 0)


def algorithm(zip_path: Path, strength: float = 0.3) -> bytes:
    result_files = {}

    with zipfile.ZipFile(zip_path) as zip_archive:
        for entry in zip_archive.infolist():
            relative = PurePosixPath(entry.filename.replace('\\', '/'))
            extension = relative.suffix.lower()
            if entry.is_dir() or extension not in {'.jpg', '.jpeg', '.png', '.bmp', '.tif', '.tiff'}:
                continue
            if relative.is_absolute() or '..' in relative.parts:
                raise ValueError('图像压缩包内包含无效路径')
            image = cv2.imdecode(np.frombuffer(zip_archive.read(entry), dtype=np.uint8), cv2.IMREAD_COLOR)
            if image is None:
                raise ValueError(f'无法读取图像：{entry.filename}；任务未完成全部输入文件')
            restored = adaptive_rain_removal(image, strength)
            success, buffer = cv2.imencode(extension, restored)
            if not success:
                raise RuntimeError(f'无法保存处理结果：{entry.filename}')
            result_files[str(relative)] = buffer.tobytes()

    result_zip_buffer = io.BytesIO()
    with zipfile.ZipFile(result_zip_buffer, "w") as result_zip:
        for filename, content in result_files.items():
            result_zip.writestr(filename, content)

    result_zip_buffer.seek(0)
    if not result_files:
        raise RuntimeError("未生成有效图像结果，请检查输入文件")
    return result_zip_buffer.read()
