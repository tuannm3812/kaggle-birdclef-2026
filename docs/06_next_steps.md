# Next Steps

## 1. Final Position

The competition run is archived with the final public ensemble notebook as the
leaderboard champion:

| Submission path | Public | Private | Role |
|---|---:|---:|---|
| `14_final_public_ensemble_taxonomy_smoothing.ipynb` | **0.950** | **0.941** | Final champion |
| `13_onnx_perch_sed_temporal_residual.ipynb` | **0.898** | N/A | Strongest project-owned ONNX blend |
| `10_onnx_perch_sed_soundscape_calibrated.ipynb` | **0.893** | N/A | Protected soundscape-calibrated baseline |
| `05_onnx_sed_submit.ipynb` | **0.822** | N/A | Strong fast SED baseline |
| `04_perch_v2_submit.ipynb` | **0.770** | N/A | Perch v2 reference |
| `02_effnet_b0.ipynb` | **0.646** | N/A | CPU-safe fallback |

The final ensemble notebook should stay on the canonical version 9 weights
`[0.020, 0.013, 0.967]`.
The version 10 through 13 weight probes all tied at
**0.950 public / 0.941 private**, so there is no reason to keep the last probe
configuration as the local notebook state.

## 2. Archive Priorities

### 2.1 Preserve Final Champion

Status: complete.

Work items:

1. Keep `14_final_public_ensemble_taxonomy_smoothing.ipynb` as the canonical
   final notebook.
2. Keep
   `notebooks/metadata/14_final_public_ensemble_taxonomy_smoothing/kernel-metadata.json`
   with the Kaggle kernel slug and attached inputs.
3. Keep `docs/14_final_public_ensemble_results.md` as the final score source of truth.
4. Treat the version 10 through 13 weight probes as recorded result variants,
   not separate notebooks.

### 2.2 Preserve Project-Owned Baselines

Status: complete.

Work items:

1. Keep `02_effnet_b0.ipynb` and `04_perch_v2_submit.ipynb` as the original
   reproducible baseline submissions.
2. Keep `05_onnx_sed_submit.ipynb` as the strong non-blended ONNX path.
3. Keep `10_onnx_perch_sed_soundscape_calibrated.ipynb` and
   `13_onnx_perch_sed_temporal_residual.ipynb` as the strongest project-owned
   blend paths.
4. Keep archived variants under `notebooks/archive/` for reproducibility, but
   do not continue editing them during cleanup.

### 2.3 Keep Operational Helpers Small

Status: retained for reproducibility.

The scripts under `scripts/` are Kaggle status helpers used during the final
submission window. They should stay small and shell-only:

- `check_final_ensemble_submission.sh`
- `watch_final_ensemble_submission.sh`
- `check_final_ensemble_weight_submissions.sh`
- `watch_final_ensemble_weight_submissions.sh`

Do not add large orchestration frameworks unless the repo is revived for a new
competition.

## 3. Research Backlog

These ideas are useful after the competition, but they should not be presented
as pending leaderboard work:

1. Build a run registry from notebook metadata, public/private scores, artifact
   inputs, and output paths.
2. Convert reusable feature extraction and submission validation code into
   small modules if another BirdCLEF season starts.
3. Compare the final ensemble route outputs against the project-owned ONNX
   blends to identify which taxa drove the `0.898 -> 0.950` jump.
4. Revisit Perch soundscape priors, weak-label diagnostics, and distillation
   only if there is a fresh validation target or a new competition split.
5. Add a lightweight CI check that validates notebook JSON and scans submission
   notebooks for missing `submission.csv` validation.

## 4. Guardrails

- Keep model artifacts, Kaggle inputs, and generated submissions outside git.
- Keep protected notebooks reproducible; avoid editing historical winners just
  for style.
- Record public references in docs before adapting them into project notebooks.
- Prefer notebook-first workflows for Kaggle submission paths, with scripts only
  for push/status operations.
- Do not interpret public dry runs as hidden-test runtime measurements.
