from pathlib import Path

from algo_support.segmentation import run_segmentation


def algorithm(zip_path: Path, model_name: str = "语义增强",
              overlay_alpha: float = 0.5, device: str = "auto") -> bytes:
    """Run the supplied ep025 training checkpoint without changing its network."""
    return run_segmentation(zip_path, model_name, overlay_alpha, device)
