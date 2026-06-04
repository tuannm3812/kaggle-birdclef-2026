# Notebook-First Run Tracker Implementation Plan

Status: historical implementation plan. The final competition archive is
documented in `docs/14_eos9_final_results.md`; notebook 14 became the final
champion after this plan was drafted.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a notebook-first Kaggle run tracker with metadata validation,
run/submission CSV records, Kaggle CLI push support, tests, and docs links.

**Architecture:** Keep model logic in Kaggle notebooks. Add a small local
control plane under `tools/kaggle_runs/` and durable records under `docs/runs/`.
Use standard-library Python so the workflow works without installing project
dependencies.

**Tech Stack:** Python standard library (`argparse`, `csv`, `json`,
`subprocess`, `unittest`), Kaggle CLI, Markdown, CSV.

---

## File Structure

- Create `docs/runs/README.md`: explains the run tracker, fields, workflow,
  and artifact policy.
- Create `docs/runs/runs.csv`: append-only Kaggle notebook execution ledger.
- Create `docs/runs/submissions.csv`: protected leaderboard result ledger seeded
  with known scores.
- Create `notebooks/metadata/13_onnx_perch_sed_temporal_residual.kernel-metadata.json`:
  Kaggle CLI metadata for the active notebook.
- Create `tools/kaggle_runs/__init__.py`: marks the helper package.
- Create `tools/kaggle_runs/common.py`: shared constants, path validation, CSV
  helpers, metadata loading, and artifact-policy checks.
- Create `tools/kaggle_runs/validate_metadata.py`: validates one metadata file.
- Create `tools/kaggle_runs/record_run.py`: appends or updates run rows and
  optionally appends submission rows.
- Create `tools/kaggle_runs/push_kernel.py`: validates metadata and invokes
  `kaggle kernels push`, with dry-run support.
- Create `tests/tools/kaggle_runs/test_validate_metadata.py`: unit tests for
  metadata validation.
- Create `tests/tools/kaggle_runs/test_record_run.py`: unit tests for run and
  submission recording.
- Modify `README.md`: link to the run tracker.
- Modify `docs/06_next_steps.md`: add tracker usage to the recommended order.
- Modify `notebooks/README.md`: link active notebook metadata and tracker.

## Task 1: Create Tracker Docs And Seed CSVs

**Files:**
- Create: `docs/runs/README.md`
- Create: `docs/runs/runs.csv`
- Create: `docs/runs/submissions.csv`

- [ ] **Step 1: Create `docs/runs/README.md`**

```markdown
# Kaggle Run Tracker

This folder records Kaggle notebook executions and preserved leaderboard
submissions for the BirdCLEF+ 2026 project.

The notebooks remain the executable source of truth. These records make Kaggle
runs reproducible without tracking audio, model weights, ONNX files, credentials,
or local Kaggle working directories.

## Files

| File | Purpose |
|---|---|
| `runs.csv` | One row per Kaggle notebook execution attempt |
| `submissions.csv` | One row per meaningful leaderboard result |

## Workflow

1. Update the active notebook.
2. Validate its metadata with `tools/kaggle_runs/validate_metadata.py`.
3. Push it with `tools/kaggle_runs/push_kernel.py`.
4. Record the pushed run with `tools/kaggle_runs/record_run.py`.
5. After Kaggle finishes, update the same `run_id` with score, status, runtime,
   outputs, and notes.
6. Promote meaningful leaderboard results into `submissions.csv`.

## Artifact Policy

Track lightweight records only. Do not commit:

- `kaggle.json`
- Raw audio or Kaggle datasets
- Model weights or checkpoints
- ONNX files
- NumPy arrays
- Compressed artifact archives
- Local Kaggle working directories
```

- [ ] **Step 2: Create `docs/runs/runs.csv`**

```csv
run_id,date,notebook,kaggle_kernel_ref,kaggle_version,purpose,status,public_score,runtime_notes,attached_inputs,outputs,notes
```

- [ ] **Step 3: Create `docs/runs/submissions.csv`**

```csv
submission_id,run_id,date,notebook,public_score,role,is_protected,attached_inputs,artifact_outputs,reproduction_notes,next_action
effnet_b0_v9,,2026-06-03,notebooks/02_effnet_b0.ipynb,0.646,protected_baseline,true,See docs/04_effnet_b0_results.md,,Protected PyTorch fallback; exact Kaggle version and inputs should be filled when reproduced,Keep unchanged
perch_v2_v14,,2026-06-03,notebooks/04_perch_v2_submit.ipynb,0.770,protected_baseline,true,See docs/05_perch_v2_results.md,,Protected Perch v2 reference; exact Kaggle version and inputs should be filled when reproduced,Keep unchanged
onnx_sed_v2,,2026-06-03,notebooks/05_onnx_sed_submit.ipynb,0.822,protected_baseline,true,See docs/09_onnx_sed_results.md,,Protected ONNX SED baseline,Keep unchanged
onnx_perch_sed_exact_v2,,2026-06-03,notebooks/archive/07_onnx_perch_sed_blend.ipynb,0.890,protected_baseline,true,See docs/11_onnx_perch_sed_blend_results.md,,Historical exact-mapped ONNX Perch plus SED blend,Keep archived
onnx_perch_sed_proxy6_v1,,2026-06-03,notebooks/archive/09_onnx_perch_sed_blend_proxy6.ipynb,0.892,protected_baseline,true,See docs/11_onnx_perch_sed_blend_results.md,,Historical narrow proxy-mapped blend,Keep archived
onnx_perch_sed_calibrated_v2,,2026-06-03,notebooks/10_onnx_perch_sed_soundscape_calibrated.ipynb,0.893,protected_baseline,true,See docs/13_soundscape_calibration_diagnostics.md,soundscape_blend_calibration.csv,Protected soundscape-calibrated baseline,Keep unchanged
onnx_perch_sed_temporal_residual_v2,,2026-06-04,notebooks/13_onnx_perch_sed_temporal_residual.ipynb,0.898,protected_baseline,true,See docs/11_onnx_perch_sed_blend_results.md,temporal_residual_history.csv,Strongest project-owned ONNX blend,Keep unchanged
eos9_final_v9,,2026-06-04,notebooks/14_eos9_public_ensemble_taxonomy_smoothing.ipynb,0.950,final_champion,true,See docs/14_eos9_final_results.md,submission.csv,Final public/private score 0.950/0.941,Keep canonical v9 weights
```

- [ ] **Step 4: Verify CSV headers**

Run:

```bash
python3 - <<'PY'
import csv
from pathlib import Path

for path in [Path("docs/runs/runs.csv"), Path("docs/runs/submissions.csv")]:
    with path.open(newline="") as handle:
        rows = list(csv.reader(handle))
    assert rows, f"{path} is empty"
    assert all(rows[0]), f"{path} has blank header cells"
    print(path, len(rows[0]), "columns")
PY
```

Expected:

```text
docs/runs/runs.csv 12 columns
docs/runs/submissions.csv 11 columns
```

- [ ] **Step 5: Commit tracker docs and seed CSVs**

```bash
git add docs/runs/README.md docs/runs/runs.csv docs/runs/submissions.csv
git commit -m "Add Kaggle run tracker records"
```

## Task 2: Add Active Notebook Kaggle Metadata

**Files:**
- Create: `notebooks/metadata/13_onnx_perch_sed_temporal_residual.kernel-metadata.json`

- [ ] **Step 1: Create metadata directory and file**

```json
{
  "id": "tuanmnguyen/birdclef-2026-onnx-perch-sed-temporal-residual",
  "title": "BirdCLEF+ 2026 ONNX Perch SED Temporal Residual",
  "code_file": "../13_onnx_perch_sed_temporal_residual.ipynb",
  "language": "python",
  "kernel_type": "notebook",
  "is_private": true,
  "enable_gpu": false,
  "enable_internet": false,
  "dataset_sources": [
    "kaggle/competitions/birdclef-2026"
  ],
  "competition_sources": [
    "birdclef-2026"
  ],
  "kernel_sources": []
}
```

- [ ] **Step 2: Confirm the referenced notebook exists**

Run:

```bash
python3 - <<'PY'
import json
from pathlib import Path

metadata = Path("notebooks/metadata/13_onnx_perch_sed_temporal_residual.kernel-metadata.json")
data = json.loads(metadata.read_text())
notebook = (metadata.parent / data["code_file"]).resolve()
assert notebook.exists(), notebook
assert notebook.name == "13_onnx_perch_sed_temporal_residual.ipynb"
print(notebook)
PY
```

Expected: prints the absolute path to notebook `13`.

- [ ] **Step 3: Commit metadata**

```bash
git add notebooks/metadata/13_onnx_perch_sed_temporal_residual.kernel-metadata.json
git commit -m "Add Kaggle metadata for temporal residual notebook"
```

## Task 3: Add Shared Kaggle Run Helper Library

**Files:**
- Create: `tools/kaggle_runs/__init__.py`
- Create: `tools/kaggle_runs/common.py`

- [ ] **Step 1: Create `tools/kaggle_runs/__init__.py`**

```python
"""Helpers for tracking and pushing Kaggle notebook runs."""
```

- [ ] **Step 2: Create `tools/kaggle_runs/common.py`**

```python
"""Shared helpers for Kaggle run tracking tools."""

from __future__ import annotations

import csv
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


REPO_ROOT = Path(__file__).resolve().parents[2]

RUN_COLUMNS = [
    "run_id",
    "date",
    "notebook",
    "kaggle_kernel_ref",
    "kaggle_version",
    "purpose",
    "status",
    "public_score",
    "runtime_notes",
    "attached_inputs",
    "outputs",
    "notes",
]

SUBMISSION_COLUMNS = [
    "submission_id",
    "run_id",
    "date",
    "notebook",
    "public_score",
    "role",
    "is_protected",
    "attached_inputs",
    "artifact_outputs",
    "reproduction_notes",
    "next_action",
]

REQUIRED_METADATA_FIELDS = [
    "id",
    "title",
    "code_file",
    "language",
    "kernel_type",
    "is_private",
    "enable_gpu",
    "enable_internet",
    "dataset_sources",
    "competition_sources",
    "kernel_sources",
]

DISALLOWED_SUFFIXES = {
    ".ckpt",
    ".env",
    ".npy",
    ".npz",
    ".onnx",
    ".parquet",
    ".pt",
    ".pth",
    ".zip",
}

DISALLOWED_NAMES = {"kaggle.json"}
DISALLOWED_PARTS = {
    "artifacts",
    "data",
    "kaggle",
    "local_artifacts",
    "models",
    "outputs",
}


@dataclass(frozen=True)
class MetadataValidation:
    """Result from validating a Kaggle metadata file."""

    metadata_path: Path
    notebook_path: Path
    kernel_ref: str


def repo_path(path: Path | str) -> Path:
    """Return an absolute path inside the repository."""

    candidate = Path(path)
    if not candidate.is_absolute():
        candidate = REPO_ROOT / candidate
    return candidate.resolve()


def relative_to_repo(path: Path) -> str:
    """Return a POSIX relative path from the repository root."""

    return path.resolve().relative_to(REPO_ROOT).as_posix()


def load_json(path: Path | str) -> dict:
    """Load a JSON object from disk."""

    metadata_path = repo_path(path)
    with metadata_path.open(encoding="utf-8") as handle:
        data = json.load(handle)
    if not isinstance(data, dict):
        raise ValueError(f"{metadata_path} must contain a JSON object")
    return data


def validate_metadata(path: Path | str) -> MetadataValidation:
    """Validate Kaggle kernel metadata and its notebook reference."""

    metadata_path = repo_path(path)
    data = load_json(metadata_path)
    missing = [key for key in REQUIRED_METADATA_FIELDS if key not in data]
    if missing:
        raise ValueError(
            f"{relative_to_repo(metadata_path)} missing fields: "
            f"{', '.join(missing)}"
        )
    if data["language"] != "python":
        raise ValueError("language must be 'python'")
    if data["kernel_type"] != "notebook":
        raise ValueError("kernel_type must be 'notebook'")
    if not isinstance(data["dataset_sources"], list):
        raise ValueError("dataset_sources must be a list")
    if not isinstance(data["competition_sources"], list):
        raise ValueError("competition_sources must be a list")
    if not isinstance(data["kernel_sources"], list):
        raise ValueError("kernel_sources must be a list")

    notebook_path = (metadata_path.parent / data["code_file"]).resolve()
    notebooks_root = (REPO_ROOT / "notebooks").resolve()
    if not notebook_path.exists():
        raise ValueError(f"Referenced notebook does not exist: {notebook_path}")
    if notebook_path.suffix != ".ipynb":
        raise ValueError("code_file must reference an .ipynb notebook")
    if not notebook_path.is_relative_to(notebooks_root):
        raise ValueError("code_file must point inside notebooks/")
    ensure_allowed_tracked_paths([metadata_path, notebook_path])
    return MetadataValidation(
        metadata_path=metadata_path,
        notebook_path=notebook_path,
        kernel_ref=str(data["id"]),
    )


def ensure_allowed_tracked_paths(paths: Iterable[Path | str]) -> None:
    """Reject credential, data, model, and bulky artifact paths."""

    for raw_path in paths:
        path = repo_path(raw_path)
        rel = path.relative_to(REPO_ROOT)
        parts = set(rel.parts)
        if path.name in DISALLOWED_NAMES:
            raise ValueError(f"Refusing to track credential file: {rel}")
        if path.suffix in DISALLOWED_SUFFIXES:
            raise ValueError(f"Refusing to track artifact file: {rel}")
        if parts & DISALLOWED_PARTS:
            matched = ", ".join(sorted(parts & DISALLOWED_PARTS))
            raise ValueError(f"Refusing to track ignored path {rel}: {matched}")


def read_csv_rows(path: Path | str, columns: list[str]) -> list[dict[str, str]]:
    """Read CSV rows and verify the header."""

    csv_path = repo_path(path)
    with csv_path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames != columns:
            raise ValueError(
                f"{relative_to_repo(csv_path)} header mismatch: "
                f"{reader.fieldnames}"
            )
        return [dict(row) for row in reader]


def write_csv_rows(
    path: Path | str, columns: list[str], rows: list[dict[str, str]]
) -> None:
    """Write rows with a stable CSV header."""

    csv_path = repo_path(path)
    csv_path.parent.mkdir(parents=True, exist_ok=True)
    with csv_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=columns)
        writer.writeheader()
        for row in rows:
            writer.writerow({column: row.get(column, "") for column in columns})
```

- [ ] **Step 3: Run import smoke check**

Run:

```bash
python3 - <<'PY'
from tools.kaggle_runs.common import RUN_COLUMNS, SUBMISSION_COLUMNS

assert len(RUN_COLUMNS) == 12
assert len(SUBMISSION_COLUMNS) == 11
print("common helpers import")
PY
```

Expected:

```text
common helpers import
```

- [ ] **Step 4: Commit shared helper library**

```bash
git add tools/kaggle_runs/__init__.py tools/kaggle_runs/common.py
git commit -m "Add shared Kaggle run helper library"
```

## Task 4: Add Metadata Validation Tests And CLI

**Files:**
- Create: `tests/tools/kaggle_runs/test_validate_metadata.py`
- Create: `tools/kaggle_runs/validate_metadata.py`

- [ ] **Step 1: Write failing metadata validation tests**

```python
import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from tools.kaggle_runs import common


VALID_METADATA = {
    "id": "user/kernel",
    "title": "Valid Kernel",
    "code_file": "../13_onnx_perch_sed_temporal_residual.ipynb",
    "language": "python",
    "kernel_type": "notebook",
    "is_private": True,
    "enable_gpu": False,
    "enable_internet": False,
    "dataset_sources": ["kaggle/competitions/birdclef-2026"],
    "competition_sources": ["birdclef-2026"],
    "kernel_sources": [],
}


class ValidateMetadataTests(unittest.TestCase):
    def test_valid_metadata_returns_notebook_and_kernel_ref(self):
        path = (
            common.REPO_ROOT
            / "notebooks/metadata/"
            / "13_onnx_perch_sed_temporal_residual.kernel-metadata.json"
        )

        result = common.validate_metadata(path)

        self.assertEqual(result.kernel_ref, "tuanmnguyen/birdclef-2026-onnx-perch-sed-temporal-residual")
        self.assertEqual(
            result.notebook_path.name,
            "13_onnx_perch_sed_temporal_residual.ipynb",
        )

    def test_missing_required_field_is_rejected(self):
        with tempfile.TemporaryDirectory(dir=common.REPO_ROOT) as temp_dir:
            metadata_dir = Path(temp_dir) / "notebooks" / "metadata"
            metadata_dir.mkdir(parents=True)
            notebook_dir = Path(temp_dir) / "notebooks"
            notebook = notebook_dir / "test.ipynb"
            notebook.write_text("{}", encoding="utf-8")
            data = dict(VALID_METADATA)
            data.pop("id")
            data["code_file"] = "../test.ipynb"
            path = metadata_dir / "kernel-metadata.json"
            path.write_text(json.dumps(data), encoding="utf-8")

            with mock.patch.object(common, "REPO_ROOT", Path(temp_dir)):
                with self.assertRaisesRegex(ValueError, "missing fields: id"):
                    common.validate_metadata(path)

    def test_notebook_outside_notebooks_is_rejected(self):
        with tempfile.TemporaryDirectory(dir=common.REPO_ROOT) as temp_dir:
            metadata_dir = Path(temp_dir) / "notebooks" / "metadata"
            metadata_dir.mkdir(parents=True)
            outside = Path(temp_dir) / "outside.ipynb"
            outside.write_text("{}", encoding="utf-8")
            data = dict(VALID_METADATA)
            data["code_file"] = "../../outside.ipynb"
            path = metadata_dir / "kernel-metadata.json"
            path.write_text(json.dumps(data), encoding="utf-8")

            with mock.patch.object(common, "REPO_ROOT", Path(temp_dir)):
                with self.assertRaisesRegex(ValueError, "inside notebooks"):
                    common.validate_metadata(path)

    def test_disallowed_artifact_path_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "artifact file"):
            common.ensure_allowed_tracked_paths(["models/model.onnx"])


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Run tests and verify they fail before CLI exists**

Run:

```bash
python3 -m unittest tests.tools.kaggle_runs.test_validate_metadata -v
```

Expected: tests that import `common` should pass if Task 3 is complete. This
step is still a red check for the task because the CLI file has not been added.

- [ ] **Step 3: Create `tools/kaggle_runs/validate_metadata.py`**

```python
"""Validate Kaggle kernel metadata for project notebooks."""

from __future__ import annotations

import argparse

from tools.kaggle_runs.common import relative_to_repo, validate_metadata


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments."""

    parser = argparse.ArgumentParser(
        description="Validate Kaggle kernel metadata."
    )
    parser.add_argument("metadata", help="Path to kernel metadata JSON")
    return parser.parse_args()


def main() -> int:
    """Run metadata validation."""

    args = parse_args()
    result = validate_metadata(args.metadata)
    print(f"Metadata: {relative_to_repo(result.metadata_path)}")
    print(f"Notebook: {relative_to_repo(result.notebook_path)}")
    print(f"Kernel: {result.kernel_ref}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

- [ ] **Step 4: Run validation tests**

Run:

```bash
python3 -m unittest tests.tools.kaggle_runs.test_validate_metadata -v
```

Expected: all tests pass.

- [ ] **Step 5: Run validation CLI**

Run:

```bash
python3 tools/kaggle_runs/validate_metadata.py \
  notebooks/metadata/13_onnx_perch_sed_temporal_residual.kernel-metadata.json
```

Expected:

```text
Metadata: notebooks/metadata/13_onnx_perch_sed_temporal_residual.kernel-metadata.json
Notebook: notebooks/13_onnx_perch_sed_temporal_residual.ipynb
Kernel: tuanmnguyen/birdclef-2026-onnx-perch-sed-temporal-residual
```

- [ ] **Step 6: Commit validator**

```bash
git add tests/tools/kaggle_runs/test_validate_metadata.py tools/kaggle_runs/validate_metadata.py
git commit -m "Add Kaggle metadata validator"
```

## Task 5: Add Run Recording Tests And CLI

**Files:**
- Create: `tests/tools/kaggle_runs/test_record_run.py`
- Create: `tools/kaggle_runs/record_run.py`

- [ ] **Step 1: Write failing run recorder tests**

```python
import csv
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from tools.kaggle_runs import common
from tools.kaggle_runs import record_run


class RecordRunTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(dir=common.REPO_ROOT)
        self.root = Path(self.temp.name)
        self.runs_path = self.root / "docs/runs/runs.csv"
        self.submissions_path = self.root / "docs/runs/submissions.csv"
        self.runs_path.parent.mkdir(parents=True)
        common.write_csv_rows(self.runs_path, common.RUN_COLUMNS, [])
        common.write_csv_rows(
            self.submissions_path, common.SUBMISSION_COLUMNS, []
        )
        self.repo_patch = mock.patch.object(common, "REPO_ROOT", self.root)
        self.repo_patch.start()

    def tearDown(self):
        self.repo_patch.stop()
        self.temp.cleanup()

    def read_rows(self, path):
        with path.open(newline="", encoding="utf-8") as handle:
            return list(csv.DictReader(handle))

    def test_append_run_row(self):
        args = record_run.RecordArgs(
            run_id="run-001",
            date="2026-06-03",
            notebook="notebooks/13_onnx_perch_sed_temporal_residual.ipynb",
            kaggle_kernel_ref="user/kernel",
            kaggle_version="1",
            purpose="Temporal residual test",
            status="pushed",
            public_score="",
            runtime_notes="",
            attached_inputs="birdclef-2026",
            outputs="",
            notes="initial push",
        )

        record_run.upsert_run(args)

        rows = self.read_rows(self.runs_path)
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0]["run_id"], "run-001")
        self.assertEqual(rows[0]["status"], "pushed")

    def test_duplicate_run_id_requires_update_flag(self):
        args = record_run.RecordArgs(
            run_id="run-001",
            date="2026-06-03",
            notebook="notebooks/13_onnx_perch_sed_temporal_residual.ipynb",
            kaggle_kernel_ref="user/kernel",
            kaggle_version="1",
            purpose="Temporal residual test",
            status="pushed",
            public_score="",
            runtime_notes="",
            attached_inputs="birdclef-2026",
            outputs="",
            notes="initial push",
        )
        record_run.upsert_run(args)

        with self.assertRaisesRegex(ValueError, "already exists"):
            record_run.upsert_run(args)

    def test_update_existing_run(self):
        original = record_run.RecordArgs(
            run_id="run-001",
            date="2026-06-03",
            notebook="notebooks/13_onnx_perch_sed_temporal_residual.ipynb",
            kaggle_kernel_ref="user/kernel",
            kaggle_version="1",
            purpose="Temporal residual test",
            status="pushed",
            public_score="",
            runtime_notes="",
            attached_inputs="birdclef-2026",
            outputs="",
            notes="initial push",
        )
        updated = record_run.RecordArgs(
            run_id="run-001",
            date="2026-06-03",
            notebook="notebooks/13_onnx_perch_sed_temporal_residual.ipynb",
            kaggle_kernel_ref="user/kernel",
            kaggle_version="1",
            purpose="Temporal residual test",
            status="complete",
            public_score="0.894",
            runtime_notes="finished hidden scoring",
            attached_inputs="birdclef-2026",
            outputs="submission.csv",
            notes="improved champion",
        )
        record_run.upsert_run(original)

        record_run.upsert_run(updated, update=True)

        rows = self.read_rows(self.runs_path)
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0]["status"], "complete")
        self.assertEqual(rows[0]["public_score"], "0.894")

    def test_append_submission_row(self):
        args = record_run.SubmissionArgs(
            submission_id="sub-001",
            run_id="run-001",
            date="2026-06-03",
            notebook="notebooks/13_onnx_perch_sed_temporal_residual.ipynb",
            public_score="0.894",
            role="champion",
            is_protected="true",
            attached_inputs="birdclef-2026",
            artifact_outputs="submission.csv",
            reproduction_notes="Kaggle version 1",
            next_action="Protect notebook",
        )

        record_run.append_submission(args)

        rows = self.read_rows(self.submissions_path)
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0]["submission_id"], "sub-001")
        self.assertEqual(rows[0]["role"], "champion")


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Run tests and verify import fails before implementation**

Run:

```bash
python3 -m unittest tests.tools.kaggle_runs.test_record_run -v
```

Expected: fail because `tools.kaggle_runs.record_run` does not exist yet.

- [ ] **Step 3: Create `tools/kaggle_runs/record_run.py`**

```python
"""Record Kaggle notebook runs and meaningful submissions."""

from __future__ import annotations

import argparse
from dataclasses import asdict, dataclass

from tools.kaggle_runs.common import (
    RUN_COLUMNS,
    SUBMISSION_COLUMNS,
    read_csv_rows,
    repo_path,
    write_csv_rows,
)


RUNS_PATH = "docs/runs/runs.csv"
SUBMISSIONS_PATH = "docs/runs/submissions.csv"


@dataclass(frozen=True)
class RecordArgs:
    """Run row values."""

    run_id: str
    date: str
    notebook: str
    kaggle_kernel_ref: str
    kaggle_version: str
    purpose: str
    status: str
    public_score: str
    runtime_notes: str
    attached_inputs: str
    outputs: str
    notes: str


@dataclass(frozen=True)
class SubmissionArgs:
    """Submission row values."""

    submission_id: str
    run_id: str
    date: str
    notebook: str
    public_score: str
    role: str
    is_protected: str
    attached_inputs: str
    artifact_outputs: str
    reproduction_notes: str
    next_action: str


def upsert_run(args: RecordArgs, update: bool = False) -> None:
    """Append or update one run row."""

    rows = read_csv_rows(RUNS_PATH, RUN_COLUMNS)
    row = asdict(args)
    matches = [idx for idx, item in enumerate(rows) if item["run_id"] == args.run_id]
    if matches and not update:
        raise ValueError(f"run_id already exists: {args.run_id}")
    if update and not matches:
        raise ValueError(f"run_id not found for update: {args.run_id}")
    if update:
        rows[matches[0]] = row
    else:
        rows.append(row)
    write_csv_rows(RUNS_PATH, RUN_COLUMNS, rows)


def append_submission(args: SubmissionArgs) -> None:
    """Append one submission row."""

    rows = read_csv_rows(SUBMISSIONS_PATH, SUBMISSION_COLUMNS)
    if any(row["submission_id"] == args.submission_id for row in rows):
        raise ValueError(f"submission_id already exists: {args.submission_id}")
    rows.append(asdict(args))
    write_csv_rows(SUBMISSIONS_PATH, SUBMISSION_COLUMNS, rows)


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments."""

    parser = argparse.ArgumentParser(description="Record a Kaggle run.")
    parser.add_argument("--run-id", required=True)
    parser.add_argument("--date", required=True)
    parser.add_argument("--notebook", required=True)
    parser.add_argument("--kaggle-kernel-ref", default="")
    parser.add_argument("--kaggle-version", default="")
    parser.add_argument("--purpose", default="")
    parser.add_argument("--status", required=True)
    parser.add_argument("--public-score", default="")
    parser.add_argument("--runtime-notes", default="")
    parser.add_argument("--attached-inputs", default="")
    parser.add_argument("--outputs", default="")
    parser.add_argument("--notes", default="")
    parser.add_argument("--update", action="store_true")
    parser.add_argument("--submission-id", default="")
    parser.add_argument("--submission-role", default="")
    parser.add_argument("--submission-protected", default="false")
    parser.add_argument("--artifact-outputs", default="")
    parser.add_argument("--reproduction-notes", default="")
    parser.add_argument("--next-action", default="")
    return parser.parse_args()


def main() -> int:
    """Record a run and optional submission."""

    args = parse_args()
    notebook_path = repo_path(args.notebook)
    if not notebook_path.exists():
        raise ValueError(f"Notebook does not exist: {args.notebook}")
    run_args = RecordArgs(
        run_id=args.run_id,
        date=args.date,
        notebook=args.notebook,
        kaggle_kernel_ref=args.kaggle_kernel_ref,
        kaggle_version=args.kaggle_version,
        purpose=args.purpose,
        status=args.status,
        public_score=args.public_score,
        runtime_notes=args.runtime_notes,
        attached_inputs=args.attached_inputs,
        outputs=args.outputs,
        notes=args.notes,
    )
    upsert_run(run_args, update=args.update)
    print(f"Recorded run {args.run_id}")

    if args.submission_id:
        submission_args = SubmissionArgs(
            submission_id=args.submission_id,
            run_id=args.run_id,
            date=args.date,
            notebook=args.notebook,
            public_score=args.public_score,
            role=args.submission_role,
            is_protected=args.submission_protected,
            attached_inputs=args.attached_inputs,
            artifact_outputs=args.artifact_outputs,
            reproduction_notes=args.reproduction_notes,
            next_action=args.next_action,
        )
        append_submission(submission_args)
        print(f"Recorded submission {args.submission_id}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

- [ ] **Step 4: Run run recorder tests**

Run:

```bash
python3 -m unittest tests.tools.kaggle_runs.test_record_run -v
```

Expected: all tests pass.

- [ ] **Step 5: Run full helper test suite**

Run:

```bash
python3 -m unittest discover -s tests -v
```

Expected: all tests pass.

- [ ] **Step 6: Commit recorder**

```bash
git add tests/tools/kaggle_runs/test_record_run.py tools/kaggle_runs/record_run.py
git commit -m "Add Kaggle run recorder"
```

## Task 6: Add Kaggle Push Helper

**Files:**
- Create: `tools/kaggle_runs/push_kernel.py`

- [ ] **Step 1: Create push helper**

```python
"""Push a validated notebook to Kaggle with optional dry-run mode."""

from __future__ import annotations

import argparse
import shutil
import subprocess
from pathlib import Path

from tools.kaggle_runs.common import relative_to_repo, validate_metadata


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments."""

    parser = argparse.ArgumentParser(description="Push a notebook to Kaggle.")
    parser.add_argument("notebook", help="Notebook path under notebooks/")
    parser.add_argument(
        "--metadata",
        help="Metadata path. Defaults to notebooks/metadata/<stem>.kernel-metadata.json",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the Kaggle command without running it.",
    )
    return parser.parse_args()


def default_metadata_for_notebook(notebook: str) -> Path:
    """Return the default metadata path for a notebook path."""

    notebook_path = Path(notebook)
    return (
        Path("notebooks")
        / "metadata"
        / f"{notebook_path.stem}.kernel-metadata.json"
    )


def build_command(metadata_path: Path) -> list[str]:
    """Build the Kaggle CLI command."""

    return ["kaggle", "kernels", "push", "-p", str(metadata_path.parent)]


def main() -> int:
    """Validate metadata and push the kernel."""

    args = parse_args()
    metadata_path = Path(args.metadata) if args.metadata else default_metadata_for_notebook(args.notebook)
    result = validate_metadata(metadata_path)
    requested = Path(args.notebook).resolve()
    if requested.name != result.notebook_path.name:
        raise ValueError(
            "Notebook argument does not match metadata code_file: "
            f"{args.notebook} != {relative_to_repo(result.notebook_path)}"
        )
    command = build_command(result.metadata_path)
    print("Notebook:", relative_to_repo(result.notebook_path))
    print("Metadata:", relative_to_repo(result.metadata_path))
    print("Kernel:", result.kernel_ref)
    print("Command:", " ".join(command))
    if args.dry_run:
        return 0
    if shutil.which("kaggle") is None:
        raise RuntimeError("Kaggle CLI not found on PATH")
    completed = subprocess.run(command, check=False)
    return completed.returncode


if __name__ == "__main__":
    raise SystemExit(main())
```

- [ ] **Step 2: Run dry-run push helper**

Run:

```bash
python3 tools/kaggle_runs/push_kernel.py \
  notebooks/13_onnx_perch_sed_temporal_residual.ipynb \
  --dry-run
```

Expected:

```text
Notebook: notebooks/13_onnx_perch_sed_temporal_residual.ipynb
Metadata: notebooks/metadata/13_onnx_perch_sed_temporal_residual.kernel-metadata.json
Kernel: tuanmnguyen/birdclef-2026-onnx-perch-sed-temporal-residual
Command: kaggle kernels push -p notebooks/metadata
```

- [ ] **Step 3: Run full helper test suite**

Run:

```bash
python3 -m unittest discover -s tests -v
```

Expected: all tests pass.

- [ ] **Step 4: Commit push helper**

```bash
git add tools/kaggle_runs/push_kernel.py
git commit -m "Add Kaggle kernel push helper"
```

## Task 7: Link Tracker From Project Docs

**Files:**
- Modify: `README.md`
- Modify: `docs/06_next_steps.md`
- Modify: `notebooks/README.md`

- [ ] **Step 1: Update `README.md` after the model result links**

Add:

```markdown
Run tracking and reproducibility records:

- [Kaggle run tracker](docs/runs/README.md)
- [Run ledger](docs/runs/runs.csv)
- [Submission ledger](docs/runs/submissions.csv)
```

- [ ] **Step 2: Update `docs/06_next_steps.md` guardrails**

Add this guardrail:

```markdown
- Record Kaggle notebook executions in `docs/runs/runs.csv`, and promote only
  meaningful leaderboard results into `docs/runs/submissions.csv`.
```

- [ ] **Step 3: Update `notebooks/README.md` active notebook lane**

Add after the active lane table:

```markdown
Kaggle CLI metadata for the active notebook lives in
`notebooks/metadata/13_onnx_perch_sed_temporal_residual.kernel-metadata.json`.
Record pushes and results in `docs/runs/`.
```

- [ ] **Step 4: Check docs references**

Run:

```bash
rg -n "docs/runs|notebooks/metadata" README.md docs/06_next_steps.md notebooks/README.md
```

Expected: each of the three files has at least one match.

- [ ] **Step 5: Commit docs links**

```bash
git add README.md docs/06_next_steps.md notebooks/README.md
git commit -m "Link Kaggle run tracker from docs"
```

## Task 8: Final Verification

**Files:**
- Verify all files from Tasks 1-7.

- [ ] **Step 1: Run unit tests**

Run:

```bash
python3 -m unittest discover -s tests -v
```

Expected: all tests pass.

- [ ] **Step 2: Validate active notebook metadata**

Run:

```bash
python3 tools/kaggle_runs/validate_metadata.py \
  notebooks/metadata/13_onnx_perch_sed_temporal_residual.kernel-metadata.json
```

Expected:

```text
Metadata: notebooks/metadata/13_onnx_perch_sed_temporal_residual.kernel-metadata.json
Notebook: notebooks/13_onnx_perch_sed_temporal_residual.ipynb
Kernel: tuanmnguyen/birdclef-2026-onnx-perch-sed-temporal-residual
```

- [ ] **Step 3: Dry-run Kaggle push**

Run:

```bash
python3 tools/kaggle_runs/push_kernel.py \
  notebooks/13_onnx_perch_sed_temporal_residual.ipynb \
  --dry-run
```

Expected: prints the Kaggle push command and exits with status 0.

- [ ] **Step 4: Check tracked files for disallowed artifacts**

Run:

```bash
python3 - <<'PY'
from pathlib import Path
import subprocess

from tools.kaggle_runs.common import ensure_allowed_tracked_paths

tracked = subprocess.check_output(
    ["git", "ls-files"], text=True
).splitlines()
ensure_allowed_tracked_paths([Path(path) for path in tracked])
print("tracked files pass artifact policy")
PY
```

Expected:

```text
tracked files pass artifact policy
```

- [ ] **Step 5: Check git status**

Run:

```bash
git status --short
```

Expected: no output.

- [ ] **Step 6: Completion summary**

Report:

```text
Implemented notebook-first Kaggle run tracker.
Verified unit tests, metadata validation, push dry-run, and artifact policy.
```

## Self-Review

Spec coverage:

- Run tracker records are covered by Tasks 1 and 5.
- Kaggle metadata template is covered by Task 2.
- Validation, push, and record helpers are covered by Tasks 3-6.
- Documentation links are covered by Task 7.
- Artifact policy and final checks are covered by Tasks 3, 4, 6, and 8.
- Score roadmap support is covered by seeded submissions and docs linkage.

Red-flag scan:

- No deferred-detail markers or incomplete steps are present.
- Each code-writing step includes concrete file contents.
- Each verification step includes exact commands and expected results.

Type consistency:

- `RecordArgs`, `SubmissionArgs`, `RUN_COLUMNS`, and `SUBMISSION_COLUMNS` are
  defined before tests or CLI usage.
- `validate_metadata`, `ensure_allowed_tracked_paths`, `read_csv_rows`, and
  `write_csv_rows` are defined in `common.py` before consumer tasks.
- The metadata filename matches the active notebook stem used by
  `push_kernel.py`.
