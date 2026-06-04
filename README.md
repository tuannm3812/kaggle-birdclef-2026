# BirdCLEF+ 2026

<p align="center">
  <img src="https://www.birds.cornell.edu/home/wp-content/uploads/2018/11/aab.jpg" alt="Cornell Lab bird soundscape" width="100%">
</p>

<p align="center">
  <a href="https://www.kaggle.com/competitions/birdclef-2026">
    <img src="https://img.shields.io/badge/Kaggle-BirdCLEF%2B%202026-20BEFF?logo=kaggle&logoColor=white" alt="Kaggle competition">
  </a>
  <img src="https://img.shields.io/badge/Workflow-Notebook--first-F37626?logo=jupyter" alt="Notebook-first workflow">
  <img src="https://img.shields.io/badge/Final-Public%200.950%20%7C%20Private%200.941-2EA44F" alt="Final score">
</p>

BirdCLEF+ 2026 bioacoustic classification workspace for Brazilian Pantanal
soundscapes. The repository is now a post-competition research archive: it
preserves the final leaderboard notebook, the project-owned baseline notebooks,
Kaggle metadata, operational scripts, and result notes needed to understand the
full experiment path.

## Final Result

| Result | Value |
|---|---:|
| Final champion | `14_eos9_public_ensemble_taxonomy_smoothing.ipynb` |
| Public leaderboard | **0.950** |
| Private leaderboard | **0.941** |
| Canonical blend weights | `[0.020, 0.013, 0.967]` |
| Best project-owned ONNX blend | **0.898** public |
| Strong simple ONNX baseline | **0.822** public |

The final notebook adapts the reviewed EoS.9 public ensemble into the project
style, keeps the three active inference routes, enables taxonomy smoothing, and
validates the generated `submission.csv`. Four final weight probes tied the
canonical score, so the repository keeps version 9 as the reproducible champion.

Final score details: [docs/14_eos9_final_results.md](docs/14_eos9_final_results.md).

## Competition Context

BirdCLEF+ 2026 asks participants to identify wildlife species in hidden
1-minute Pantanal soundscape recordings. Each soundscape is scored as **12
contiguous 5-second windows**, and each row in `submission.csv` contains
probabilities for **234** target species columns.

This is a multi-taxon soundscape task rather than a bird-only clean-clip task.
The target set includes birds, amphibians, mammals, reptiles, and insects, so
calibration, domain shift, class imbalance, and CPU-safe hidden-test inference
are central constraints.

## Project Progression

| Stage | Notebook | Public score | Role |
|---|---|---:|---|
| EDA | `01_eda.ipynb` | N/A | Dataset, label, and soundscape audit |
| EfficientNet-B0 | `02_effnet_b0.ipynb` | **0.646** | PyTorch fallback |
| Perch v2 probe | `03`, `04` notebooks | **0.770** | Transfer-learning reference |
| Distilled SED ONNX | `05_onnx_sed_submit.ipynb` | **0.822** | Strong simple ONNX baseline |
| ONNX Perch + SED proxy blend | `archive/09_onnx_perch_sed_blend_proxy6.ipynb` | **0.892** | Mapping milestone |
| Soundscape-calibrated blend | `10_onnx_perch_sed_soundscape_calibrated.ipynb` | **0.893** | Protected baseline |
| Temporal residual blend | `13_onnx_perch_sed_temporal_residual.ipynb` | **0.898** | Best project-owned ONNX blend |
| EoS.9 public ensemble | `14_eos9_public_ensemble_taxonomy_smoothing.ipynb` | **0.950** | Final champion, **0.941** private |

The main score jump came from moving from direct Perch and compact SED
baselines to richer ensemble routes while preserving a notebook-first Kaggle
submission workflow.

## Repository Layout

```text
notebooks/
  01_eda.ipynb
  02_effnet_b0.ipynb
  03_perch_v2_train.ipynb
  04_perch_v2_submit.ipynb
  05_onnx_sed_submit.ipynb
  06_onnx_perch_speed_test.ipynb
  10_onnx_perch_sed_soundscape_calibrated.ipynb
  13_onnx_perch_sed_temporal_residual.ipynb
  14_eos9_public_ensemble_taxonomy_smoothing.ipynb
  metadata/
  archive/

docs/
  01_project_overview.md
  02_coding_standards.md
  03_eda_insights.md
  04_effnet_b0_results.md
  05_perch_v2_results.md
  06_next_steps.md
  07_distilled_sed_review.md
  08_protossm_review.md
  09_onnx_sed_results.md
  10_onnx_perch_speed_results.md
  11_onnx_perch_sed_blend_results.md
  12_perch_mapping_diagnostics.md
  13_soundscape_calibration_diagnostics.md
  14_eos9_final_results.md

scripts/
  check_notebook14_submission.sh
  check_notebook14_weight_submissions.sh
  watch_notebook14_submission.sh
  watch_notebook14_weight_submissions.sh
```

Generated submissions, Kaggle datasets, model weights, ONNX files, waveform
caches, and local artifacts stay outside git.

## Maintained Notebooks

| Notebook | Purpose |
|---|---|
| [01_eda.ipynb](notebooks/01_eda.ipynb) | Dataset audit, label coverage, soundscape diagnostics, and EDA figures |
| [02_effnet_b0.ipynb](notebooks/02_effnet_b0.ipynb) | EfficientNet-B0 training and CPU-safe submission fallback |
| [03_perch_v2_train.ipynb](notebooks/03_perch_v2_train.ipynb) | Perch v2 probe training, diagnostics, calibration, and artifact packaging |
| [04_perch_v2_submit.ipynb](notebooks/04_perch_v2_submit.ipynb) | Lean Perch v2 CPU scoring notebook |
| [05_onnx_sed_submit.ipynb](notebooks/05_onnx_sed_submit.ipynb) | Protected distilled SED ONNX baseline |
| [06_onnx_perch_speed_test.ipynb](notebooks/06_onnx_perch_speed_test.ipynb) | ONNX Perch runtime experiment |
| [10_onnx_perch_sed_soundscape_calibrated.ipynb](notebooks/10_onnx_perch_sed_soundscape_calibrated.ipynb) | Protected soundscape-calibrated ONNX blend |
| [13_onnx_perch_sed_temporal_residual.ipynb](notebooks/13_onnx_perch_sed_temporal_residual.ipynb) | Best project-owned ONNX blend |
| [14_eos9_public_ensemble_taxonomy_smoothing.ipynb](notebooks/14_eos9_public_ensemble_taxonomy_smoothing.ipynb) | Final archived EoS.9 champion |

Historical experiments live under [notebooks/archive](notebooks/archive). See
[notebooks/README.md](notebooks/README.md) for promotion and preservation
rules.

## Key Findings

- Training data contains **35,549** recordings across **206** primary labels.
- The submission contract requires **234** target probability columns.
- Labeled train soundscapes deduplicate from **1,478** rows to **739** unique
  5-second windows.
- The task has severe class imbalance: median class size is **125**, with a
  range of **1-499** recordings.
- Foundation bioacoustic features and public ensemble diversity transferred far
  better than a small CNN trained from scratch.
- Public notebook dry runs are not reliable hidden-test runtime checks because
  hidden `test_soundscapes/` are only mounted during scoring.

Full EDA notes: [docs/03_eda_insights.md](docs/03_eda_insights.md).

## Reproducibility Notes

- Kaggle remains the execution environment for submission notebooks.
- Notebook 14 metadata is tracked at
  [notebooks/metadata/14_eos9_public_ensemble_taxonomy_smoothing/kernel-metadata.json](notebooks/metadata/14_eos9_public_ensemble_taxonomy_smoothing/kernel-metadata.json).
- The final Kaggle kernel slug is
  `tuannm3812/birdclef-2026-eos9-public-ensemble-taxonomy`.
- Direct CSV upload returned a Kaggle `400` response for this code competition;
  final submissions were made by pushing notebook versions and submitting the
  generated kernel output.
- The scripts in `scripts/` are lightweight Kaggle status helpers. They expect
  the Kaggle CLI and allow `KAGGLE_CLI` / `KAGGLE_CONFIG_DIR` overrides.

## Documentation Index

| Document | Purpose |
|---|---|
| [Project overview](docs/01_project_overview.md) | Competition framing and solution architecture |
| [Coding standards](docs/02_coding_standards.md) | Notebook and code conventions |
| [EDA insights](docs/03_eda_insights.md) | Dataset and soundscape findings |
| [EfficientNet-B0 results](docs/04_effnet_b0_results.md) | PyTorch baseline notes |
| [Perch v2 results](docs/05_perch_v2_results.md) | Perch probe results and diagnostics |
| [ONNX SED results](docs/09_onnx_sed_results.md) | Distilled SED milestone |
| [ONNX Perch speed results](docs/10_onnx_perch_speed_results.md) | CPU runtime experiment |
| [ONNX Perch + SED blend results](docs/11_onnx_perch_sed_blend_results.md) | Blend history and interpretation |
| [Soundscape calibration diagnostics](docs/13_soundscape_calibration_diagnostics.md) | Calibration analysis |
| [EoS.9 final results](docs/14_eos9_final_results.md) | Final public/private result record |
| [Next steps](docs/06_next_steps.md) | Post-competition archive and research backlog |
