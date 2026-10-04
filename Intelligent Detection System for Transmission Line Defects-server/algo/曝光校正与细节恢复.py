import io
from pathlib import Path
import zipfile
import os
import tempfile
import cv2
import numpy as np


class CleanExposureCorrector:
    def __init__(self):
        self.min_brightness = 60
        self.max_brightness = 200

    def load_image(self, path):
        img = cv2.imdecode(np.fromfile(path, dtype=np.uint8), cv2.IMREAD_COLOR)
        if img is None:
            return None
        return cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    def analyze_exposure(self, image):
        gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
        mean = np.mean(gray)
        dark_ratio = np.mean(gray < self.min_brightness)
        bright_ratio = np.mean(gray > self.max_brightness)

        if dark_ratio > 0.35 and bright_ratio > 0.15:
            t = "backlight"
        elif bright_ratio > 0.3:
            t = "overexposed"
        elif mean < 90:
            t = "underexposed"
        else:
            t = "normal"

        return {
            "type": t,
            "mean": float(mean),
            "dark_ratio": float(dark_ratio),
            "bright_ratio": float(bright_ratio)
        }

    def adjust_gamma(self, img, gamma):
        inv = 1.0 / gamma
        table = np.array([(i / 255.0) ** inv * 255 for i in range(256)]).astype("uint8")
        return cv2.LUT(img, table)

    def clahe_luminance(self, img):
        lab = cv2.cvtColor(img, cv2.COLOR_RGB2LAB)
        l, a, b = cv2.split(lab)
        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
        l2 = clahe.apply(l)
        lab = cv2.merge((l2, a, b))
        return cv2.cvtColor(lab, cv2.COLOR_LAB2RGB)

    def compress_highlights(self, img, strength=1.1):
        f = img.astype(np.float32) / 255.0
        f = f ** strength
        return np.clip(f * 255, 0, 255).astype(np.uint8)

    def enhance_saturation(self, img, factor=1.05):
        hsv = cv2.cvtColor(img, cv2.COLOR_RGB2HSV)
        h, s, v = cv2.split(hsv)
        s = np.clip(s.astype(np.float32) * factor, 0, 255).astype(np.uint8)
        hsv = cv2.merge((h, s, v))
        return cv2.cvtColor(hsv, cv2.COLOR_HSV2RGB)

    def process_backlight(self, img):
        img = self.adjust_gamma(img, 0.85)
        img = self.clahe_luminance(img)
        img = self.compress_highlights(img, 1.12)
        img = self.enhance_saturation(img, 1.05)
        return img

    def process_overexposed(self, img):
        img = self.adjust_gamma(img, 1.2)
        img = self.compress_highlights(img, 1.15)
        img = self.clahe_luminance(img)
        return img

    def process_underexposed(self, img):
        img = self.adjust_gamma(img, 0.75)
        img = self.clahe_luminance(img)
        img = self.enhance_saturation(img, 1.08)
        return img

    def process_normal(self, img):
        img = self.adjust_gamma(img, 0.95)
        img = self.clahe_luminance(img)
        return img

    def process_image(self, img):
        info = self.analyze_exposure(img)
        t = info["type"]

        if t == "backlight":
            out = self.process_backlight(img)
        elif t == "overexposed":
            out = self.process_overexposed(img)
        elif t == "underexposed":
            out = self.process_underexposed(img)
        else:
            out = self.process_normal(img)

        return out


def algorithm(zip_path: Path) -> bytes:
    result_files = {}

    with tempfile.TemporaryDirectory() as temp_dir:
        with zipfile.ZipFile(zip_path) as zip_archive:
            zip_archive.extractall(temp_dir)

        corrector = CleanExposureCorrector()

        for current_dir, subdirs, files in os.walk(temp_dir):
            for filename in files:
                file_path = os.path.join(current_dir, filename)
                file_extension = filename.split('.')[-1].lower()

                if file_extension not in ['jpg', 'jpeg', 'png', 'bmp']:
                    continue

                try:
                    img = corrector.load_image(file_path)
                    if img is None:
                        continue

                    result_img = corrector.process_image(img)

                    is_success, buffer = cv2.imencode('.' + file_extension, cv2.cvtColor(result_img, cv2.COLOR_RGB2BGR))
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
