# Notebook-First Run Tracker Design

## 1. Purpose

Build a reusable research workflow for this BirdCLEF+ 2026 repository while
keeping Kaggle notebooks as the executable source of truth.

The project should support both goals:

1. Improve competition score through disciplined experiment lanes.
2. Preserve reproducibility through explicit Kaggle run, submission, input, and
   artifact records.

The design is intentionally notebook-first because training and scoring happen
on Kaggle, and the Kaggle CLI can push notebooks without requiring local model
execution.

## 2. Scope

In scope:

- Add a local run tracker for Kaggle notebook executions and leaderboard
  submissions.
- Add Kaggle CLI metadata templates for pushed notebooks.
- Add thin local helpers for metadata validation, kernel push, and run record
  updates.
- Seed the tracker with known protected submissions and current champion
  results.
- Link tracker records from the main documentation.
- Keep active score work focused on one notebook lane at a time.

Out of scope:

- Extracting notebook model logic into a `src/` package.
- Running model training locally.
- Tracking raw audio, model weights, ONNX files, Kaggle credentials, or bulky
  generated artifacts in git.
- Replacing Kaggle as the execution environment.

## 3. Architecture

The repository remains notebook-first.

```text
notebooks/
  13_onnx_perch_sed_temporal_residual.ipynb
  metadata/
    13_onnx_perch_sed_temporal_residual.kernel-metadata.json

docs/
  runs/
    README.md
    runs.csv
    submissions.csv
  superpowers/
    specs/
      2026-06-03-notebook-first-run-tracker-design.md

tools/
  kaggle_runs/
    validate_metadata.py
    push_kernel.py
    record_run.py
```

Responsibilities:

- `notebooks/` owns modeling, training, inference, and submission logic.
- `notebooks/metadata/` owns Kaggle CLI metadata templates for pushed
  notebooks.
- `docs/runs/` owns durable run and submission records.
- `tools/kaggle_runs/` owns local workflow helpers only.
- Protected champion notebooks stay unchanged unless intentionally promoted.

This gives the repo a reusable control plane without introducing a package that
must be synced into Kaggle.

## 4. Run Tracker Data Model

The tracker records two related entities: runs and submissions.

A run is a Kaggle notebook execution attempt. It may or may not produce a
leaderboard submission.

`docs/runs/runs.csv` columns:

```text
run_id
date
notebook
kaggle_kernel_ref
kaggle_version
purpose
status
public_score
runtime_notes
attached_inputs
outputs
notes
```

A submission is a result worth preserving or comparing.

`docs/runs/submissions.csv` columns:

```text
submission_id
run_id
date
notebook
public_score
role
is_protected
attached_inputs
artifact_outputs
reproduction_notes
next_action
```

Supported submission roles:

- `champion`
- `protected_baseline`
- `failed_variant`
- `active_experiment`
- `diagnostic_run`

This split lets the project preserve routine Kaggle executions separately from
meaningful leaderboard results.

## 5. Kaggle CLI Workflow

The workflow should be repeatable and explicit:

1. Update the active notebook.
2. Validate its Kaggle metadata.
3. Push the notebook with Kaggle CLI.
4. Record the pushed run intent locally.
5. After Kaggle finishes, update the run with status, runtime, outputs, score,
   and notes.
6. Promote meaningful results into `submissions.csv`.
7. Update model result docs only when a run changes the project decision.

Expected helper commands:

```bash
python tools/kaggle_runs/validate_metadata.py \
  notebooks/metadata/13_onnx_perch_sed_temporal_residual.kernel-metadata.json

python tools/kaggle_runs/push_kernel.py \
  notebooks/13_onnx_perch_sed_temporal_residual.ipynb

python tools/kaggle_runs/record_run.py \
  --notebook notebooks/13_onnx_perch_sed_temporal_residual.ipynb \
  --status pushed
```

Helper constraints:

- Helpers may call `kaggle kernels push`.
- Helpers must not train locally.
- Helpers must not parse large Kaggle artifacts.
- Helpers require network access only for explicit Kaggle operations.
- Helpers must refuse to track credentials, raw audio, model weights, ONNX
  files, NumPy arrays, compressed artifact archives, or ignored Kaggle working
  directories.

## 6. Score Improvement Roadmap

The project should keep one active score-improvement lane at a time.

Recommended order:

1. Complete and evaluate
   `notebooks/13_onnx_perch_sed_temporal_residual.ipynb`.
2. Record every Kaggle execution of notebook `13` in `docs/runs/runs.csv`.
3. Promote meaningful leaderboard results into `docs/runs/submissions.csv`.
4. Choose the next experiment lane only after notebook `13` has a clear result.
5. Avoid tiny calibration tuning unless diagnostics show a specific question it
   answers.

Notebook `13` is the right active lane because it reuses the current 0.893
soundscape-calibrated champion path while testing a controlled temporal
residual model. If it fails, the project should treat that as evidence to move
toward model diversity, final submission safety, or external high-scoring
ideas, not more scalar calibration tuning.

## 7. Reproducibility Roadmap

Recommended order:

1. Create `docs/runs/README.md`, `docs/runs/runs.csv`, and
   `docs/runs/submissions.csv`.
2. Seed `submissions.csv` with known protected results:
   - EfficientNet-B0 public score 0.646.
   - Perch v2 public score 0.770.
   - ONNX SED public score 0.822.
   - ONNX Perch + SED exact blend public score 0.890.
   - ONNX Perch + SED proxy6 public score 0.892.
   - ONNX Perch + SED soundscape-calibrated champion public score 0.893.
3. Add Kaggle metadata for active notebook `13`.
4. Add metadata for protected notebooks only when they need to be pushed or
   reproduced.
5. Add thin validation, push, and record helpers.
6. Link the run tracker from `README.md`, `docs/06_next_steps.md`, and
   `notebooks/README.md`.

## 8. Error Handling

Metadata validation should fail with clear messages when:

- Required Kaggle metadata fields are missing.
- The referenced notebook path does not exist.
- Metadata points at a notebook outside `notebooks/`.
- A tracked file matches ignored artifact or credential patterns.
- The Kaggle CLI is required but unavailable.

Run recording should avoid silent overwrites. Updating an existing run should
require an explicit `run_id`. Creating a new run should generate or require a
unique `run_id`.

Kaggle push helpers should surface the underlying CLI command and exit code so
failures are easy to diagnose.

## 9. Testing

Testing should focus on local tracker correctness, not model quality.

Minimum checks:

- Metadata validator accepts the notebook `13` metadata template.
- Metadata validator rejects missing required fields.
- Metadata validator rejects disallowed artifact paths.
- Run recorder appends a new run row with the expected columns.
- Run recorder updates an existing run only when an explicit `run_id` is
  provided.
- CSV headers remain stable.

Manual verification:

- Confirm docs link to the tracker.
- Confirm `.gitignore` still excludes credentials, data, models, outputs,
  artifacts, local Kaggle directories, and large model files.
- Use the push helper dry-run mode before any real Kaggle push.

## 10. Success Criteria

The design is complete when:

- The repo can answer which notebook produced each protected score.
- Each protected submission records its Kaggle inputs, role, and reproduction
  notes.
- The active notebook can be pushed through a documented Kaggle CLI path.
- Kaggle execution results can be recorded without editing multiple docs by
  hand.
- Model code still lives in notebooks, so Kaggle remains the execution source
  of truth.
- No private credentials or bulky artifacts are tracked.
