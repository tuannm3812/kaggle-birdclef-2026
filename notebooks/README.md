# Notebook Structure

Keep this folder small. Notebooks should be promoted here only when they are
project-owned, reproducible, and tied to a documented experiment.

## Key Notebooks

These are the notebooks that tell the project story and should stay visible at
the top level.

| Notebook | Role |
|---|---|
| `01_eda.ipynb` | Dataset audit and figures |
| `02_effnet_b0.ipynb` | Protected EfficientNet-B0 fallback and submission path |
| `03_perch_v2_train.ipynb` | Perch probe training, diagnostics, and artifact packaging |
| `04_soundscape_calibrated_blend.ipynb` | Protected soundscape-calibrated baseline submission |
| `05_temporal_residual_blend.ipynb` | Protected temporal residual blend submission |
| `06_final_public_ensemble_taxonomy_smoothing.ipynb` | Final archived public ensemble champion submission |

## Support References

These notebooks are useful for reproducing specific submissions or runtime
checks, but they are not part of the main notebook story.

| Notebook | Role |
|---|---|
| `support/04_perch_v2_submission_reference.ipynb` | Protected Perch v2 submission reference |
| `support/05_distilled_sed_submission_reference.ipynb` | Protected distilled SED ONNX baseline submission |
| `support/06_onnx_perch_runtime_probe.ipynb` | ONNX Perch runtime experiment |

## Archived Experiments

These are preserved for reproducibility, but should not be edited unless a
historical result needs to be audited.

| Notebook | Role |
|---|---|
| `archive/07_onnx_perch_sed_blend.ipynb` | Historical 0.890 exact ONNX Perch + SED blend |
| `archive/08_onnx_perch_sed_blend_w025.ipynb` | Historical Perch weight 0.25 variant |
| `archive/09_onnx_perch_sed_blend_proxy6.ipynb` | Historical 0.892 narrow proxy-mapping milestone |
| `archive/11_onnx_perch_sed_calibrated_min10_ap001.ipynb` | Historical support-thresholded calibration variant |
| `archive/12_onnx_perch_sed_calibrated_shrink050.ipynb` | Historical shrunk-calibration variant |

## Final Notebook Lane

The competition run is archived. The final lane is:

| Notebook | Purpose |
|---|---|
| `06_final_public_ensemble_taxonomy_smoothing.ipynb` | Canonical version 9 final public ensemble adaptation with taxonomy smoothing, **0.950 public / 0.941 private** |

Do not add separate notebooks for every public reference. Review external
notebooks in `docs/`, then promote only the cleaned project-owned version.

## Run Output Status

Some early notebooks are intentionally committed with outputs cleared to keep
the repository lightweight. Their Kaggle results are preserved in the matching
result documents.

| Notebook | Local output state | Result evidence |
|---|---|---|
| `01_eda.ipynb` | Outputs cleared | EDA figures and `docs/03_eda_insights.md` |
| `02_effnet_b0.ipynb` | Outputs cleared | `docs/04_effnet_b0_results.md` |
| `03_perch_v2_train.ipynb` | Outputs cleared | `docs/05_perch_v2_results.md` |
| `04_soundscape_calibrated_blend.ipynb` | Kaggle outputs retained | `docs/13_soundscape_calibration_diagnostics.md` |
| `05_temporal_residual_blend.ipynb` | Kaggle outputs retained | `docs/11_onnx_perch_sed_blend_results.md` |
| `06_final_public_ensemble_taxonomy_smoothing.ipynb` | Outputs cleared | `docs/14_final_public_ensemble_results.md` and Kaggle metadata |

## Perch v2 Policy

Keep `03_perch_v2_train.ipynb` and `support/04_perch_v2_submission_reference.ipynb`. They preserve
the Perch baseline path and artifact history. Do not keep iterating on direct
TensorFlow Perch CPU submission unless we need to reproduce version 14; future
leaderboard work should use notebook-first ONNX or ensemble notebooks.

## Promotion Rules

1. A top-level notebook must be part of the project narrative.
2. Pure submission or runtime helper notebooks belong in `support/`.
3. Historical score variants belong in `archive/`.
4. Public-reference notebooks stay in `docs/*_review.md`, not in this folder.
5. Protected baselines should not be overwritten by experiments.
6. New experiments should update `docs/15_post_competition_roadmap.md` before
   another notebook is added.
