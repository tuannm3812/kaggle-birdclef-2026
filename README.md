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
soundscapes. The repository records the modeling path from dataset audit to a
final public ensemble submission, with the reasoning, experiments, and
key notebooks kept in a notebook-first workflow.

## Final Result

| Result | Value |
|---|---:|
| Final champion | `06_final_public_ensemble_taxonomy_smoothing.ipynb` |
| Public leaderboard | **0.950** |
| Private leaderboard | **0.941** |
| Canonical blend weights | `[0.020, 0.013, 0.967]` |
| Best project-owned ONNX blend | **0.898** public |
| Strong simple ONNX baseline | **0.822** public |

The final notebook adapts a reviewed public ensemble reference into the project
style, keeps the three selected inference routes, enables taxonomy smoothing,
and validates the generated `submission.csv`. Four final weight probes tied the
canonical score, so the repository keeps version 9 as the reproducible champion.

Final score details: [docs/14_final_public_ensemble_results.md](docs/14_final_public_ensemble_results.md).

## Competition Context

BirdCLEF+ 2026 asks participants to identify wildlife species in hidden
1-minute Pantanal soundscape recordings. Each soundscape is scored as **12
contiguous 5-second windows**, and each row in `submission.csv` contains
probabilities for **234** target species columns.

This is a multi-taxon soundscape task rather than a bird-only clean-clip task.
The target set includes birds, amphibians, mammals, reptiles, and insects, so
calibration, domain shift, class imbalance, and CPU-safe hidden-test inference
are central constraints.

## Solution Logic

The project started with EDA because the scoring setup is not a clean-clip
classification problem. Hidden scoring uses long soundscapes, overlapping
species, sparse calls, and 234 output columns, while the main training set is
mostly focal recordings with 206 primary labels.

The first modeling goal was therefore reliability, not leaderboard score.
EfficientNet-B0 established a simple PyTorch baseline and confirmed the
submission contract. Perch v2 then improved representation quality through
pretrained bioacoustic embeddings, but direct TensorFlow Perch inference was a
runtime risk for hidden Kaggle scoring.

The next phase moved the submission path to ONNX. Distilled SED handled all
234 target columns with CPU-safe inference. ONNX Perch then became a lightweight
additional signal rather than the full submitted model. Exact label mapping,
targeted proxy mapping, and soundscape-calibrated blend weights each added
small controlled gains.

The final jump came from model diversity. The final public ensemble combined
stronger public inference routes with taxonomy smoothing, while keeping the
project's submission validation and result tracking style. The final archived
configuration reached **0.950 public / 0.941 private**.

## Project Progression

| Stage | Evidence | Public score | Role |
|---|---|---:|---|
| EDA | `01_eda.ipynb` | N/A | Dataset, label, and soundscape audit |
| EfficientNet-B0 | `02_effnet_b0.ipynb` | **0.646** | PyTorch fallback |
| Perch v2 probe | `03_perch_v2_train.ipynb` | **0.770** | Transfer-learning reference |
| Distilled SED ONNX | Result note | **0.822** | Strong simple ONNX baseline |
| ONNX Perch + SED proxy blend | Archived variant | **0.892** | Mapping milestone |
| Soundscape-calibrated blend | `04_soundscape_calibrated_blend.ipynb` | **0.893** | Protected baseline |
| Temporal residual blend | `05_temporal_residual_blend.ipynb` | **0.898** | Best project-owned ONNX blend |
| Final public ensemble | `06_final_public_ensemble_taxonomy_smoothing.ipynb` | **0.950** | Final champion, **0.941** private |

The main score jump came from moving from direct Perch and compact SED
baselines to richer ensemble routes while preserving a notebook-first Kaggle
submission workflow.

## Lessons Learned

- Soundscape labels are more valuable than clean-clip validation alone because
  they match the hidden scoring domain more closely.
- Full output coverage matters. Moving from 206 train-primary classes to the
  full 234-column submission contract was a major alignment step.
- Inference runtime is part of model quality on Kaggle. A strong model that
  cannot score hidden soundscapes inside the limit is not a usable submission.
- Perch was most useful as a feature source, teacher, or blended ONNX signal,
  not as a direct TensorFlow submission path.
- Small calibration and proxy-mapping changes helped, but their ceiling was
  limited. The largest final gain came from model diversity plus taxonomy-aware
  smoothing.
- Public dry runs are incomplete runtime tests because hidden `test_soundscapes/`
  are only mounted during scoring.

## Key Notebooks

| Notebook | Purpose |
|---|---|
| [01_eda.ipynb](notebooks/01_eda.ipynb) | Dataset audit, label coverage, soundscape diagnostics, and EDA figures |
| [02_effnet_b0.ipynb](notebooks/02_effnet_b0.ipynb) | EfficientNet-B0 training and CPU-safe submission fallback |
| [03_perch_v2_train.ipynb](notebooks/03_perch_v2_train.ipynb) | Perch v2 probe training, diagnostics, calibration, and artifact packaging |
| [04_soundscape_calibrated_blend.ipynb](notebooks/04_soundscape_calibrated_blend.ipynb) | Protected soundscape-calibrated ONNX blend |
| [05_temporal_residual_blend.ipynb](notebooks/05_temporal_residual_blend.ipynb) | Best project-owned ONNX blend |
| [06_final_public_ensemble_taxonomy_smoothing.ipynb](notebooks/06_final_public_ensemble_taxonomy_smoothing.ipynb) | Final archived public ensemble champion |

Pure submission references and runtime probes live under `notebooks/support/`.
Historical variants live under [notebooks/archive](notebooks/archive). See
[notebooks/README.md](notebooks/README.md) for promotion and preservation rules.

## Notebook Run State

| Notebook | Local output state | Evidence retained |
|---|---|---|
| `01_eda.ipynb` | Outputs cleared | EDA figures and findings in `docs/03_eda_insights.md` |
| `02_effnet_b0.ipynb` | Outputs cleared | Public score recorded in `docs/04_effnet_b0_results.md` |
| `03_perch_v2_train.ipynb` | Outputs cleared | Public score and artifact notes in `docs/05_perch_v2_results.md` |
| `04_soundscape_calibrated_blend.ipynb` | Kaggle outputs retained | Public score recorded in blend diagnostics |
| `05_temporal_residual_blend.ipynb` | Kaggle outputs retained | Public score recorded in blend diagnostics |
| `06_final_public_ensemble_taxonomy_smoothing.ipynb` | Outputs cleared | Final public/private score and Kaggle metadata retained |

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
