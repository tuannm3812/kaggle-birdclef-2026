#!/usr/bin/env python3
"""Static notebook standards checker (docs/02_coding_standards.md).

Checks notebook JSON, committed output status, and whether submission
notebooks contain a static submission.csv validation check. This does not
execute notebooks — Kaggle is the execution record, and audio/model inputs
are not available locally.

Usage:
    python3 scripts/verify_notebook_standards.py
"""

import json
import sys
from pathlib import Path
from typing import Optional

REPO_ROOT = Path(__file__).resolve().parent.parent
NOTEBOOKS_DIR = REPO_ROOT / "notebooks"

# docs/02_coding_standards.md only documents a retain/clear rule for the six
# top-level workflow notebooks. notebooks/support/ and notebooks/archive/ are
# not covered, so output status is not enforced there.
RETAIN_OUTPUTS = {
    "04_soundscape_calibrated_blend.ipynb",
    "05_temporal_residual_blend.ipynb",
}
TRACKED_TOP_LEVEL = RETAIN_OUTPUTS | {
    "01_eda.ipynb",
    "02_effnet_b0.ipynb",
    "03_perch_v2_train.ipynb",
    "06_final_public_ensemble_taxonomy_smoothing.ipynb",
}


def code_source(nb: dict) -> str:
    return "".join(
        "".join(cell.get("source", []))
        for cell in nb["cells"]
        if cell.get("cell_type") == "code"
    )


def check_json_valid(path: Path, errors: list) -> Optional[dict]:
    try:
        nb = json.loads(path.read_text())
    except (json.JSONDecodeError, OSError) as exc:
        errors.append(f"{path}: invalid notebook JSON ({exc})")
        return None
    if "cells" not in nb or "nbformat" not in nb:
        errors.append(f"{path}: missing nbformat/cells keys")
        return None
    return nb


def check_output_status(path: Path, nb: dict, errors: list) -> None:
    if path.name not in TRACKED_TOP_LEVEL:
        return
    code_cells = [c for c in nb["cells"] if c["cell_type"] == "code"]
    has_outputs = any(c.get("outputs") for c in code_cells)
    should_retain = path.name in RETAIN_OUTPUTS
    if should_retain and not has_outputs:
        errors.append(f"{path}: expected retained outputs, found none")
    if not should_retain and has_outputs:
        errors.append(f"{path}: expected cleared outputs, found outputs")


def check_submission_validation(path: Path, nb: dict, warnings: list) -> None:
    src = code_source(nb)
    if "to_csv" not in src or "submission.csv" not in src:
        return
    if "234" not in src:
        warnings.append(f"{path}: writes submission.csv without a 234-column check")
    if "isna" not in src and "isnull" not in src:
        warnings.append(f"{path}: writes submission.csv without a NaN check")


def main() -> int:
    paths = sorted(NOTEBOOKS_DIR.glob("*.ipynb"))
    for sub in ("support", "archive"):
        paths += sorted((NOTEBOOKS_DIR / sub).glob("*.ipynb"))

    errors: list = []
    warnings: list = []
    for path in paths:
        nb = check_json_valid(path, errors)
        if nb is None:
            continue
        check_output_status(path, nb, errors)
        check_submission_validation(path, nb, warnings)

    for warning in warnings:
        print(f"WARN  {warning}")
    for error in errors:
        print(f"ERROR {error}")

    if errors:
        print(f"\n{len(errors)} error(s), {len(warnings)} warning(s)")
        return 1
    print(f"OK — {len(paths)} notebooks checked, {len(warnings)} warning(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
