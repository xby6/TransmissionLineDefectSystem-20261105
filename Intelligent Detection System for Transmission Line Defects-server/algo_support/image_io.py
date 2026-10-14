"""Image and ZIP I/O compatible with Windows paths and system result storage."""
import io
import re
import zipfile
from pathlib import Path, PurePosixPath

import numpy as np
from PIL import Image


IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".tif", ".tiff"}


def iter_input_images(zip_path):
    """Read images without extracting user filenames into the filesystem."""
    with zipfile.ZipFile(zip_path) as archive:
        entries = [entry for entry in archive.infolist() if not entry.is_dir()]
        image_entries = []
        for entry in entries:
            relative = PurePosixPath(entry.filename.replace("\\", "/"))
            if relative.is_absolute() or ".." in relative.parts or ":" in str(relative):
                raise ValueError(f"输入 ZIP 包含无效路径：{entry.filename}")
            if relative.suffix.lower() in IMAGE_EXTENSIONS:
                image_entries.append((entry, relative))
        if not image_entries:
            raise ValueError("输入 ZIP 中没有可处理的 JPG、PNG、BMP 或 TIFF 图片")
        for index, (entry, relative) in enumerate(image_entries, 1):
            try:
                with Image.open(io.BytesIO(archive.read(entry))) as image:
                    image.load()
                    rgb = image.convert("RGB")
            except Exception as exc:
                raise ValueError(f"无法读取输入图片 {entry.filename}：{exc}") from exc
            stem = re.sub(r'[<>:"/\\|?*\x00-\x1f]', "_", relative.stem)[:80]
            # The backend indexes top-level ZIP files only. A sequence prefix also
            # prevents inputs in different folders, or with different extensions,
            # from overwriting each other's output.
            yield entry.filename, f"{index:03d}_{stem or 'image'}", rgb


def png_bytes(array):
    output = io.BytesIO()
    Image.fromarray(np.asarray(array, dtype=np.uint8)).save(output, format="PNG")
    return output.getvalue()


def save_id_map_png(path, id_map):
    """Use Pillow instead of cv2.imwrite so Chinese Windows paths work."""
    destination = Path(path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    array = np.asarray(id_map)
    dtype = np.uint8 if array.size == 0 or array.max() <= 255 else np.uint16
    Image.fromarray(array.astype(dtype)).save(destination, format="PNG")


def int_parameter(value, name, minimum, maximum):
    try:
        parsed = int(value)
        numeric = float(value)
    except (TypeError, ValueError, OverflowError) as exc:
        raise ValueError(f"{name} 必须是整数") from exc
    if isinstance(value, bool) or numeric != parsed or not minimum <= parsed <= maximum:
        raise ValueError(f"{name} 必须是 {minimum}～{maximum} 的整数")
    return parsed


def float_parameter(value, name, minimum, maximum):
    try:
        parsed = float(value)
    except (TypeError, ValueError, OverflowError) as exc:
        raise ValueError(f"{name} 必须是数值") from exc
    if isinstance(value, bool) or not np.isfinite(parsed) or not minimum <= parsed <= maximum:
        raise ValueError(f"{name} 必须在 {minimum}～{maximum} 之间")
    return parsed
