"""Verify imported algorithms through the live API without business task writes.

Run with the algorithm Python runtime after starting the system. The supplied
archives must first be extracted into --source-root; test data stays outside Git.
"""
import argparse
import ast
import csv
import hashlib
import io
import json
import sys
import time
import uuid
import zipfile
from datetime import datetime
from pathlib import Path

import numpy as np
import requests
import torch
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SERVER = ROOT / "Intelligent Detection System for Transmission Line Defects-server"
sys.path.insert(0, str(SERVER))
from algo_support.segmentation import CLASS_NAMES, load_model


MANUAL_ALGORITHMS = [
    "deeplabv3", "去雨后增强处理", "去雾恢复", "曝光校正与细节恢复",
    "电气设备缺陷检测模型算法", "电气设备语义分割模型算法",
    "逆光&曝光处理", "雨天图像处理",
]


def zip_inputs(entries):
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, "w", zipfile.ZIP_DEFLATED) as archive:
        for name, data in entries:
            archive.writestr(name, data)
    return buffer.getvalue()


def check_output(data, expected_images, kind):
    images, masks, texts, summaries = {}, {}, {}, {}
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        assert archive.testzip() is None, "Result ZIP failed integrity check"
        names = archive.namelist()
        assert names and len(names) == len(set(names)), "Empty or duplicate output names"
        for name in names:
            assert "/" not in name and "\\" not in name, "Backend cannot index nested outputs"
            raw = archive.read(name)
            assert raw, "Empty result artifact: " + name
            suffix = Path(name).suffix.lower()
            if suffix in (".png", ".jpg", ".jpeg"):
                with Image.open(io.BytesIO(raw)) as image:
                    image.load()
                    assert image.size in {tuple(size) for size in expected_images.values()}, "Unexpected image dimensions"
                    images[name] = {"size": list(image.size), "format": image.format}
                    if name.endswith(("_pred.png", "_filled_id.png")):
                        masks[name] = np.asarray(image).copy()
            elif suffix == ".txt":
                texts[name] = raw.decode("utf-8-sig")
            elif suffix == ".json":
                summaries[name] = json.loads(raw.decode("utf-8"))
            else:
                raise AssertionError("Unexpected output extension: " + name)
        count = len(expected_images)
        if kind == "template":
            assert len(texts) == count and not images
            assert all(",ok" in text for text in texts.values())
        elif kind in ("segmentation", "occlusion"):
            statistics = [value for name, value in summaries.items() if name.endswith("_statistics.json")]
            assert len(statistics) == count
            assert len(images) == count * (8 if kind == "occlusion" else 3)
            for info in statistics:
                prefix = next(name.removesuffix("_statistics.json") for name, value in summaries.items() if value is info)
                mask = masks[prefix + "_pred.png"]
                assert mask.ndim == 2 and mask.min() >= 0 and mask.max() < info["num_classes"]
                assert list(mask.shape[::-1]) == expected_images[info["source_name"]]
                assert sum(row["pixels"] for row in info["classes"]) == mask.size
                assert abs(sum(row["area_ratio_percent"] for row in info["classes"]) - 100) < 0.001
                for row in info["classes"]:
                    assert row["pixels"] == int((mask == row["class_id"]).sum())
                if not info["class_names_verified"] and info["classes"][0]["pixels"]:
                    assert "类别0:" in texts[prefix + "_statistics.txt"], "Unmapped class ID zero was omitted"
            if kind == "occlusion":
                for name, summary in summaries.items():
                    if not name.endswith("_occlusion.json"):
                        continue
                    prefix = name.removesuffix("_occlusion.json")
                    original, filled = masks[prefix + "_pred.png"], masks[prefix + "_filled_id.png"]
                    assert filled.max() < summary["num_classes"]
                    assert summary["changed_mask_pixels"] == int((original != filled).sum())
                    added = np.asarray(Image.open(io.BytesIO(archive.read(prefix + "_added_mask.png"))))
                    assert np.array_equal(added, (original != filled).astype(np.uint8) * 255)
        elif kind == "detection":
            assert len(images) == count and len(texts) == count
            for text in texts.values():
                rows = list(csv.reader(io.StringIO(text)))
                assert rows[0] == ["类别ID", "置信度", "x1", "y1", "x2", "y2"]
                for row in rows[1:]:
                    assert len(row) == 6
                    values = list(map(float, row))
                    assert np.isfinite(values).all() and 0 <= values[1] <= 1
        elif kind == "legacy_segmentation":
            assert len(images) == count and len(texts) == count
            assert all(text.startswith("Detected Classes and Area Ratio:") for text in texts.values())
        else:
            assert len(images) == count and not texts
    return {"files": names, "images": images, "texts": texts, "summaries": summaries}


def check_source_fidelity(source_root, outputs):
    """Compare against supplied inference code, rather than regenerated fixtures."""
    source = source_root / "segmentation/打包文件"
    original_model = source / "deeplabv3_plus.py"
    assert original_model.read_bytes() == (SERVER / "nets/deeplabv3_plus.py").read_bytes()
    skeleton = source_root / "occlusion/遮挡关系融合骨架"
    for name in ("mobilenetv2.py", "xception.py"):
        assert (skeleton / "nets" / name).read_bytes() == (SERVER / "nets" / name).read_bytes()
    for original, adapted in [(skeleton / "postprocess.py", SERVER / "algo_support/occlusion.py"),
                              (skeleton / "apply_filled_to_image.py", SERVER / "algo_support/reconstruction.py")]:
        def functions(path):
            return {node.name: ast.dump(node) for node in ast.parse(path.read_text(encoding="utf-8-sig")).body
                    if isinstance(node, ast.FunctionDef)}
        reference, current = functions(original), functions(adapted)
        for name in current:
            assert current[name] == reference[name], "Algorithm kernel changed: " + name
    # Execute only the original inference function; do not import its interactive
    # top-level model loading and input()/show() loop.
    tree = ast.parse((source / "predict.py").read_text(encoding="utf-8-sig"))
    function = next(node for node in tree.body if isinstance(node, ast.FunctionDef) and node.name == "infer_and_save")
    module = ast.fix_missing_locations(ast.Module(body=[function], type_ignores=[]))
    model, device, metadata = load_model("deeplabv3_plus.pth", "cpu")
    namespace = {"torch": torch, "np": np, "Image": Image, "device": device}
    exec(compile(module, str(source / "predict.py"), "exec"), namespace)
    raw_images = [skeleton / "data/input/原图1.png", skeleton / "data/input/原图2.png"]
    with zipfile.ZipFile(outputs["default-deeplabv3"]) as archive:
        for index, file in enumerate(raw_images, 1):
            with Image.open(file) as image:
                image = image.convert("RGB")
                reference_seg, reference_overlay = namespace["infer_and_save"](
                    model, image, [512, 512], 8, CLASS_NAMES)
            prefix = f"{index:03d}_{file.stem}"
            actual_seg = np.asarray(Image.open(io.BytesIO(archive.read(prefix + "_seg.png"))))
            actual_overlay = np.asarray(Image.open(io.BytesIO(archive.read(prefix + "_overlay.png"))))
            assert np.array_equal(actual_seg, np.asarray(reference_seg)), "Segmentation differs from supplied predict.py"
            assert np.array_equal(actual_overlay, np.asarray(reference_overlay)), "Overlay differs from supplied predict.py"
    return {"network_sources_identical": True, "geometry_and_texture_functions_identical": True,
            "original_predict_pixels_identical": True, "input_count": 2}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", default="http://127.0.0.1:8000")
    parser.add_argument("--source-root", type=Path, default=ROOT / "tmp/algorithm-import-20261014")
    parser.add_argument("--output", type=Path, default=ROOT / "tmp/algorithm-import-20261014/verification")
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    session = requests.Session()
    registry_response = session.get(args.url + "/list", timeout=15)
    registry_response.raise_for_status()
    registry = registry_response.json()
    models = session.get(args.url + "/model_list", timeout=15).json()
    assert set(MANUAL_ALGORITHMS) <= set(registry), "A visible manual algorithm is missing"
    skeleton = args.source_root / "occlusion/遮挡关系融合骨架"
    source_images = [skeleton / "data/input/原图1.png", skeleton / "data/input/原图2.png"]
    expected = {}
    entries = []
    for file in source_images:
        with Image.open(file) as image:
            expected[file.name] = list(image.size)
        entries.append((file.name, file.read_bytes()))
    payload = zip_inputs(entries)
    report = {"started_at": datetime.now().astimezone().isoformat(), "platform": args.url,
              "manual_algorithms": MANUAL_ALGORITHMS, "algorithm_count": len(registry),
              "model_count": len(models), "results": [], "negative_cases": [],
              "samples": [{"name": file.name, "size": expected[file.name],
                           "sha256": hashlib.sha256(file.read_bytes()).hexdigest()} for file in source_images],
              "scope": "Runtime/output/source-fidelity checks on supplied inspection images; no accuracy metrics or GPU verification; no business task records created."}
    outputs = {}

    def persist():
        (args.output / "report.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    def execute(label, name, params, data, image_sizes, kind):
        own_id = "archive-check-" + uuid.uuid4().hex
        started = time.perf_counter()
        print("START", label, flush=True)
        try:
            response = session.post(args.url + "/process", files={"file": ("input.zip", data, "application/zip")},
                                    data={"task_id": own_id, "algo_name": name, "args_json": json.dumps(params, ensure_ascii=False)},
                                    timeout=(15, 300))
        except requests.Timeout:
            session.post(args.url + "/stop", data={"task_id": own_id}, timeout=20)
            raise
        response.raise_for_status()
        details = check_output(response.content, image_sizes, kind)
        destination = args.output / (label + ".zip")
        destination.write_bytes(response.content)
        outputs[label] = destination
        item = dict(label=label, algorithm=name, args=params, http_status=response.status_code,
                    elapsed_seconds=round(time.perf_counter() - started, 2), status="passed", **details)
        report["results"].append(item)
        persist()
        print("PASS", label, item["elapsed_seconds"], "files", len(details["files"]), flush=True)
        return item

    for name, entry in registry.items():
        params = json.loads(entry["args"])
        kind = ("template" if name == "algorithm" else
                "occlusion" if name == "遮挡关系融合骨架" else
                "segmentation" if name in ("deeplabv3", "语义增强") else
                "detection" if name == "电气设备缺陷检测模型算法" else
                "legacy_segmentation" if name == "电气设备语义分割模型算法" else "enhancement")
        execute("default-" + name, name, params, payload, expected, kind)
    execute("xception-seven-ids", "deeplabv3", {"model_name": "last_epoch_weights.pth", "device": "cpu"}, payload, expected, "segmentation")
    execute("legacy-deeplab-args", "deeplabv3", {"model_name": "电气设备语义分割模型.pt"}, payload, expected, "segmentation")
    duplicate_entries = [("组一/巡检.png", entries[0][1]), ("组二/巡检.PNG", entries[1][1])]
    duplicate_sizes = {duplicate_entries[i][0]: expected[entries[i][0]] for i in range(2)}
    execute("unicode-nested-duplicate-names", "deeplabv3", {"model_name": "语义增强"},
            zip_inputs(duplicate_entries), duplicate_sizes, "segmentation")
    for mode in ("avg_soft", "shift"):
        execute("occlusion-fill-" + mode, "遮挡关系融合骨架", {"fill_mode": mode},
                payload, expected, "occlusion")
    for label, name, params, data in [
        ("unsupported-model", "deeplabv3", {"model_name": "best.pt"}, payload),
        ("invalid-fill-mode", "遮挡关系融合骨架", {"fill_mode": "unknown"}, payload),
        ("unmapped-occlusion-taxonomy", "遮挡关系融合骨架", {"model_name": "last_epoch_weights.pth"}, payload),
        ("no-input-images", "deeplabv3", {}, zip_inputs([("说明.txt", b"no images")])),
        ("corrupt-image", "deeplabv3", {}, zip_inputs([("损坏.png", b"not an image")])),
    ]:
        own_id = "archive-check-negative-" + uuid.uuid4().hex
        response = session.post(args.url + "/process", files={"file": ("input.zip", data, "application/zip")},
                                data={"task_id": own_id, "algo_name": name, "args_json": json.dumps(params, ensure_ascii=False)},
                                timeout=(15, 90))
        assert response.status_code >= 400, "Invalid input silently returned success: " + label
        report["negative_cases"].append({"label": label, "status": "passed", "http_status": response.status_code,
                                         "error": response.text[:1000]})
        persist()
        print("PASS negative", label, flush=True)
    report["source_fidelity"] = check_source_fidelity(args.source_root, outputs)
    report["running_tasks_after"] = session.get(args.url + "/running-tasks", timeout=15).json()
    assert report["running_tasks_after"] == {"running_tasks": []}
    report["finished_at"] = datetime.now().astimezone().isoformat()
    report["passed"] = True
    persist()
    print("VERIFIED", args.output / "report.json", flush=True)


if __name__ == "__main__":
    main()
