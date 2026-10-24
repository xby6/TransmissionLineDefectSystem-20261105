"""Run rain-removal regressions without cloud services or model downloads."""
import importlib.util
import io
from pathlib import Path
import sys
import tempfile
import unittest
import zipfile

import cv2
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
SERVER = ROOT / 'Intelligent Detection System for Transmission Line Defects-server'
sys.path.insert(0, str(SERVER))
spec = importlib.util.spec_from_file_location('rain_under_test', SERVER / 'algo/去雨后增强处理.py')
rain = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rain)


def paired_fixture():
    height, width = 384, 512
    x = np.linspace(45, 150, width, dtype=np.float32)[None, :]
    clean = np.repeat(np.repeat(x, height, axis=0)[:, :, None], 3, axis=2).astype(np.uint8)
    cv2.rectangle(clean, (175, 40), (220, 330), (110, 115, 120), -1)
    cv2.line(clean, (0, 240), (511, 240), (20, 20, 20), 4)
    streaks = np.zeros((height, width), np.uint8)
    rng = np.random.default_rng(20261024)
    for _ in range(180):
        sx, sy = int(rng.integers(5, width - 5)), int(rng.integers(2, height - 40))
        cv2.line(streaks, (sx, sy), (sx + int(rng.integers(-3, 4)), sy + int(rng.integers(12, 35))), 65, int(rng.integers(1, 3)))
    noisy = np.clip(clean.astype(np.int16) + streaks[:, :, None], 0, 255).astype(np.uint8)
    return clean, noisy


class RainRemovalChecks(unittest.TestCase):
    def test_paired_rain_is_removed_without_global_sharpening(self):
        clean, noisy = paired_fixture()
        result = rain.adaptive_rain_removal(noisy)
        before, after = cv2.PSNR(clean, noisy), cv2.PSNR(clean, result)
        self.assertGreater(after - before, 3.0, f'PSNR improvement too small: {before:.2f} -> {after:.2f}')
        mask = rain.detect_rain_streaks(noisy)
        np.testing.assert_array_equal(result[mask == 0], noisy[mask == 0])
        self.assertEqual(result.shape, noisy.shape)
        print(f'Paired synthetic rain PSNR: {before:.2f} -> {after:.2f} dB')

    def test_strength_zero_and_blank_scene_are_unchanged(self):
        _, noisy = paired_fixture()
        np.testing.assert_array_equal(rain.adaptive_rain_removal(noisy, 0), noisy)
        blank = np.full((80, 120, 3), 127, np.uint8)
        np.testing.assert_array_equal(rain.adaptive_rain_removal(blank), blank)
        light = rain.adaptive_rain_removal(noisy, 0.1)
        normal = rain.adaptive_rain_removal(noisy, 0.3)
        self.assertLess(np.abs(light.astype(float) - noisy).mean(), np.abs(normal.astype(float) - noisy).mean())

    def test_invalid_strength_is_explicit(self):
        image = np.zeros((20, 20, 3), np.uint8)
        for strength in [-0.1, 1.1, float('nan'), float('inf')]:
            with self.subTest(strength=strength), self.assertRaises(ValueError):
                rain.adaptive_rain_removal(image, strength)

    def test_archive_preserves_nested_names_and_both_entrypoints(self):
        _, noisy = paired_fixture()
        image_bytes = cv2.imencode('.png', noisy)[1].tobytes()
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / 'images.zip'
            with zipfile.ZipFile(source, 'w') as archive:
                archive.writestr('绝缘子/样例.png', image_bytes)
                archive.writestr('销钉/样例.png', image_bytes)
            result = rain.algorithm(source)
            with zipfile.ZipFile(io.BytesIO(result)) as archive:
                self.assertEqual(set(archive.namelist()), {'绝缘子/样例.png', '销钉/样例.png'})
                for name in archive.namelist():
                    decoded = cv2.imdecode(np.frombuffer(archive.read(name), np.uint8), cv2.IMREAD_COLOR)
                    self.assertEqual(decoded.shape, noisy.shape)
            from algo.雨天图像处理 import algorithm as alias
            with zipfile.ZipFile(io.BytesIO(alias(source))) as alias_zip, zipfile.ZipFile(io.BytesIO(result)) as direct_zip:
                self.assertTrue(all(alias_zip.read(name) == direct_zip.read(name) for name in direct_zip.namelist()))

    def test_corrupt_image_does_not_silently_return_partial_success(self):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / 'images.zip'
            with zipfile.ZipFile(source, 'w') as archive:
                archive.writestr('ok.png', cv2.imencode('.png', np.zeros((20, 20, 3), np.uint8))[1].tobytes())
                archive.writestr('坏图.png', b'not an image')
            with self.assertRaisesRegex(ValueError, '坏图.png'):
                rain.algorithm(source)


if __name__ == '__main__':
    unittest.main()
