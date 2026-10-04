import io
from pathlib import Path
import zipfile
import os
import tempfile
import cv2
import numpy as np


def adaptive_rain_removal(img, strength=0.3):
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    avg_brightness = np.mean(gray)

    if avg_brightness < 80:
        denoise_strength = 5
        contrast_strength = 1.3
        sharpen_strength = 0.1
    elif avg_brightness > 200:
        denoise_strength = 7
        contrast_strength = 1.1
        sharpen_strength = 0.05
    else:
        denoise_strength = 6
        contrast_strength = 1.2
        sharpen_strength = 0.08

    denoised = cv2.fastNlMeansDenoisingColored(
        img, None,
        h=denoise_strength * strength,
        hColor=denoise_strength * strength,
        templateWindowSize=7,
        searchWindowSize=21
    )

    lab = cv2.cvtColor(denoised, cv2.COLOR_BGR2LAB)
    l, a, b = cv2.split(lab)

    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    l = clahe.apply(l)

    enhanced = cv2.merge([l, a, b])
    enhanced = cv2.cvtColor(enhanced, cv2.COLOR_LAB2BGR)

    if sharpen_strength > 0:
        blurred = cv2.GaussianBlur(enhanced, (0, 0), 3)
        result = cv2.addWeighted(enhanced, 1 + sharpen_strength,
                                 blurred, -sharpen_strength, 0)
    else:
        result = enhanced

    return result


def algorithm(zip_path: Path, strength: float = 0.3) -> bytes:
    result_files = {}

    with tempfile.TemporaryDirectory() as temp_dir:
        with zipfile.ZipFile(zip_path) as zip_archive:
            zip_archive.extractall(temp_dir)

        for current_dir, subdirs, files in os.walk(temp_dir):
            for filename in files:
                file_path = os.path.join(current_dir, filename)
                file_extension = filename.split('.')[-1].lower()

                if file_extension not in ['jpg', 'jpeg', 'png', 'bmp']:
                    continue

                try:
                    img = cv2.imdecode(np.fromfile(file_path, dtype=np.uint8), cv2.IMREAD_COLOR)
                    if img is None:
                        continue

                    result = adaptive_rain_removal(img, strength=strength)

                    is_success, buffer = cv2.imencode('.' + file_extension, result)
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
