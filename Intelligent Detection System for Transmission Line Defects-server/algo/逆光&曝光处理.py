from pathlib import Path

from algo.曝光校正与细节恢复 import algorithm as exposure_algorithm


def algorithm(zip_path: Path) -> bytes:
    """Restore the manual's exposure entry using the existing exposure algorithm."""
    return exposure_algorithm(zip_path)
