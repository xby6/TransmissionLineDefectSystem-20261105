from pathlib import Path

from algo_support.segmentation import run_segmentation


def algorithm(zip_path: Path, model_name: str = "deeplabv3_plus.pth",
              overlay_alpha: float = 0.5, device: str = "auto") -> bytes:
    """Run the supplied DeepLab checkpoints with the system ZIP interface."""
    return run_segmentation(zip_path, model_name, overlay_alpha, device)
