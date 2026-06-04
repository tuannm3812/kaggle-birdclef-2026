# Notebook Structure

Keep this folder small. Notebooks should be promoted here only when they are
project-owned, reproducible, and tied to a documented experiment.

## Active Notebooks

| Notebook | Role |
|---|---|
| `01_eda.ipynb` | Dataset audit and figures |
| `02_effnet_b0.ipynb` | Protected EfficientNet-B0 fallback and submission path |
| `03_perch_v2_train.ipynb` | Perch probe training, diagnostics, and artifact packaging |
| `04_perch_v2_submit.ipynb` | Protected Perch v2 submission reference |
| `05_onnx_sed_submit.ipynb` | Protected distilled SED ONNX baseline submission |
| `06_onnx_perch_speed_test.ipynb` | ONNX Perch runtime experiment |
| `10_onnx_perch_sed_soundscape_calibrated.ipynb` | Protected soundscape-calibrated baseline submission |
| `13_onnx_perch_sed_temporal_residual.ipynb` | Protected temporal residual blend submission |
| `14_final_public_ensemble_taxonomy_smoothing.ipynb` | Final archived public ensemble champion submission |

## Archived Experiments

These are preserved for reproducibility, but should not be edited during the
final submission push.

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
| `14_final_public_ensemble_taxonomy_smoothing.ipynb` | Canonical version 9 final public ensemble adaptation with taxonomy smoothing, **0.950 public / 0.941 private** |

Do not add separate notebooks for every public reference. Review external
notebooks in `docs/`, then promote only the cleaned project-owned version.

## Perch v2 Policy

Keep `03_perch_v2_train.ipynb` and `04_perch_v2_submit.ipynb`. They preserve
the Perch baseline path and artifact history. Do not keep iterating on direct
TensorFlow Perch CPU submission unless we need to reproduce version 14; future
leaderboard work should use notebook-first ONNX or ensemble notebooks.

## Promotion Rules

1. A notebook must have one clear mode: EDA, training, or submission.
2. A submission notebook must avoid training and heavy diagnostics.
3. Public-reference notebooks stay in `docs/*_review.md`, not in this folder.
4. Protected baselines should not be overwritten by experiments.
5. New experiments should update `docs/06_next_steps.md` before another notebook
   is added.
