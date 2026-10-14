from pathlib import Path

from algo.去雨后增强处理 import algorithm as rain_algorithm


def algorithm(zip_path: Path, strength: float = 0.3) -> bytes:
    """Restore the manual's rainy-image entry using the existing rain algorithm."""
    return rain_algorithm(zip_path, strength)
