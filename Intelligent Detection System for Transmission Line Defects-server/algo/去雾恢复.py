import io
from pathlib import Path
import zipfile
import os
import tempfile
import cv2
import numpy as np


def dark_channel(img, size=15):
    b, g, r = cv2.split(img)
    min_img = cv2.min(cv2.min(r, g), b)
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (size, size))
    dark = cv2.erode(min_img, kernel)
    return dark


def estimate_atmospheric_light(img, dark):
    h, w = img.shape[:2]
    img_size = h * w
    num_px = max(int(img_size * 0.001), 1)
    dark_flat = dark.ravel()
    img_flat = img.reshape(-1, 3)
    indices = np.argpartition(dark_flat, -num_px)[-num_px:]
    atmos_light = np.max(img_flat[indices], axis=0)
    return atmos_light


def estimate_transmission(img, A, omega=0.95, size=15):
    img_norm = img.astype(np.float32) / np.maximum(A, 1)
    dark = dark_channel(img_norm, size)
    trans = 1 - omega * dark
    return np.clip(trans, 0.1, 1.0)


def guided_filter(I, p, radius=40, eps=1e-3):
    I = I.astype(np.float32)
    p = p.astype(np.float32)

    mean_I = cv2.boxFilter(I, -1, (radius, radius))
    mean_p = cv2.boxFilter(p, -1, (radius, radius))
    mean_Ip = cv2.boxFilter(I * p, -1, (radius, radius))

    cov_Ip = mean_Ip - mean_I * mean_p
    mean_II = cv2.boxFilter(I * I, -1, (radius, radius))
    var_I = mean_II - mean_I * mean_I

    a = cov_Ip / (var_I + eps)
    b = mean_p - a * mean_I

    mean_a = cv2.boxFilter(a, -1, (radius, radius))
    mean_b = cv2.boxFilter(b, -1, (radius, radius))

    q = mean_a * I + mean_b
    return q


def dehaze_single_image(img, omega=0.95, size=15, refine=True):
    dark = dark_channel(img, size)
    A = estimate_atmospheric_light(img, dark)
    trans = estimate_transmission(img, A, omega, size)

    if refine:
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY).astype(np.float32) / 255.0
        trans = guided_filter(gray, trans, radius=40, eps=1e-3)

    J = np.zeros_like(img, dtype=np.float32)
    for i in range(3):
        J[:, :, i] = (img[:, :, i].astype(np.float32) - A[i]) / np.maximum(trans, 0.1) + A[i]

    J = np.clip(J, 0, 255).astype(np.uint8)

    if len(J.shape) == 3:
        lab = cv2.cvtColor(J, cv2.COLOR_BGR2LAB)
        l, a, b = cv2.split(lab)

        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
        l = clahe.apply(l)

        lab = cv2.merge([l, a, b])
        J = cv2.cvtColor(lab, cv2.COLOR_LAB2BGR)

    return J


def algorithm(zip_path: Path, omega: float = 0.95, size: int = 15) -> bytes:
    result_files = {}

    with tempfile.TemporaryDirectory() as temp_dir:
        with zipfile.ZipFile(zip_path) as zip_archive:
            zip_archive.extractall(temp_dir)

        for current_dir, subdirs, files in os.walk(temp_dir):
            for filename in files:
                file_path = os.path.join(current_dir, filename)
                file_extension = filename.split('.')[-1].lower()

                if file_extension not in ['jpg', 'jpeg', 'png', 'bmp', 'tiff', 'tif']:
                    continue

                try:
                    img = cv2.imdecode(np.fromfile(file_path, dtype=np.uint8), cv2.IMREAD_COLOR)
                    if img is None:
                        continue

                    max_size = 1200
                    h, w = img.shape[:2]
                    if max(h, w) > max_size:
                        scale = max_size / max(h, w)
                        new_w = int(w * scale)
                        new_h = int(h * scale)
                        img = cv2.resize(img, (new_w, new_h))

                    dehazed_img = dehaze_single_image(
                        img, omega=omega, size=size, refine=True
                    )

                    is_success, buffer = cv2.imencode('.' + file_extension, dehazed_img)
                    if is_success:
                        result_files[filename] = buffer.tobytes()

                except Exception as e:
                    print(f"处理文件 {file_path} 时出错: {e}")

    result_zip_buffer = io.BytesIO()
    with zipfile.ZipFile(result_zip_buffer, "w") as result_zip:
        for filename, content in result_files.items():
            result_zip.writestr(filename, content)

    result_zip_buffer.seek(0)
    if not result_files:
        raise RuntimeError("未生成有效图像结果，请检查输入文件")
    return result_zip_buffer.read()
