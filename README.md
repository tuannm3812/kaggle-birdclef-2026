# BirdCLEF+ 2026

<p align="center">
  <img src="https://www.birds.cornell.edu/home/wp-content/uploads/2018/11/aab.jpg" alt="Cornell Lab bird soundscape" width="100%">
</p>

<p align="center">
  <a href="https://www.kaggle.com/competitions/birdclef-2026">
    <img src="https://img.shields.io/badge/Kaggle-BirdCLEF%2B%202026-20BEFF?logo=kaggle&logoColor=white" alt="Kaggle competition">
  </a>
  <img src="https://img.shields.io/badge/Focus-Soundscape%20shift%20%7C%20Ensemble%20diversity-2EA44F" alt="Project focus">
  <img src="https://img.shields.io/badge/Final-Public%200.950%20%7C%20Private%200.941-2EA44F" alt="Final score">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/PyTorch-EE4C2C?logo=pytorch&logoColor=white" alt="PyTorch">
  <img src="https://img.shields.io/badge/TensorFlow-FF6F00?logo=tensorflow&logoColor=white" alt="TensorFlow">
  <img src="https://img.shields.io/badge/ONNX%20Runtime-CPU%20inference-005CED" alt="ONNX Runtime">
  <img src="https://img.shields.io/badge/Bioacoustics-Perch%20v2%20%7C%20SED-6f42c1" alt="Bioacoustics">
  <img src="https://img.shields.io/badge/Notebooks-Kaggle--first-20BEFF?logo=jupyter&logoColor=white" alt="Notebook workflow">
</p>

BirdCLEF+ 2026 bioacoustic classification workspace for Brazilian Pantanal
soundscapes. The repository highlights the decisions that mattered most:
**soundscape-domain validation**, full **234-column output coverage**,
**CPU-safe inference**, Perch/SED signal blending, and final ensemble diversity.

## Highlights

- **Top-tier result**: `0.950` public / `0.941` private leaderboard score,
  driven by a validated, reproducible ensemble — not a single lucky submission.
- **Went from a 206-label training set to a 234-column submission contract**
  by treating coverage and calibration as first-class problems, not an
  afterthought.
- **Shipped under real constraints**: every submission path runs CPU-only
  inside Kaggle's scoring window, with no internet access and no runtime
  downloads — a production-inference discipline, not just a notebook that
  scores well once.
- **Model diversity over single-model tuning**: combined a distilled SED
  model with an ONNX-exported Perch v2 signal and taxonomy-aware smoothing,
  which produced a larger jump (`0.898 -> 0.950`) than any single calibration
  tweak.
- **Engineered for reproducibility**: every result is traceable to a notebook,
  a Kaggle kernel slug, and a written results doc (see [docs/](docs/)),
  backed by a static verification script
  ([scripts/verify_notebook_standards.py](scripts/verify_notebook_standards.py))
  that checks notebook hygiene before commits.

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

## Problem Framing

BirdCLEF+ 2026 asks participants to identify wildlife species in hidden
1-minute Pantanal soundscape recordings. Each soundscape is scored as **12
contiguous 5-second windows**, and each row in `submission.csv` contains
probabilities for **234** target species columns.

This is a multi-taxon soundscape task rather than a bird-only clean-clip task.
The target set includes birds, amphibians, mammals, reptiles, and insects, so
calibration, domain shift, class imbalance, and CPU-safe hidden-test inference
are central constraints.

## Key Insights

- **Hidden scoring** is closer to long soundscape detection than clean-clip
  classification, so soundscape-domain validation became the most useful
  feedback loop.
- The training set has **35,549** recordings across **206** primary labels, but
  the submission contract requires **234** target probability columns. Closing
  the **coverage gap** was more important than optimizing a narrow train-label
  model.
- Labeled train soundscapes deduplicate from **1,478** rows to **739** unique
  5-second windows. That small set is limited, but it exposes the domain shift
  that clean-clip validation misses.
- **Class imbalance** is severe: median class size is **125**, with a range of
  **1-499** recordings. Calibration and blending were more reliable than
  treating all labels as equally observed.
- **Inference runtime** is part of model quality on Kaggle. A strong model that
  cannot score hidden soundscapes inside the limit is not a usable submission.
- Perch was most useful as a feature source, teacher, or blended ONNX signal,
  not as a direct TensorFlow submission path.
- Small calibration and proxy-mapping changes helped, but their ceiling was
  limited. The largest final gain came from **model diversity** plus
  taxonomy-aware smoothing.

Full EDA notes: [docs/03_eda_insights.md](docs/03_eda_insights.md).

## Engineering Highlights

Skills and practices this project put into practice, beyond model accuracy:

- **Transfer learning & distillation**: adapted pretrained Perch v2 bioacoustic
  embeddings and distilled a compact SED model for fast, CPU-safe inference.
- **Model export & runtime optimization**: converted TensorFlow/PyTorch models
  to ONNX to meet Kaggle's CPU-only scoring limit, after confirming direct
  TensorFlow Perch inference was a runtime risk.
- **Calibration & ensembling**: soundscape-domain calibration, proxy-label
  mapping, and weighted ensemble blending, each validated against held-out
  soundscape windows rather than clean-clip accuracy.
- **Domain-shift-aware validation**: identified that hidden scoring behaves
  like long-soundscape detection, not clean-clip classification, and built a
  soundscape-specific validation loop instead of trusting train-set metrics.
- **Reproducible experiment tracking**: every promoted notebook is paired with
  a Kaggle kernel-metadata file and a written results doc, so any leaderboard
  number can be traced back to its exact notebook version and inputs.
- **Codebase hygiene at scale**: enforced notebook naming, output-clearing,
  and submission-validation conventions (see
  [docs/02_coding_standards.md](docs/02_coding_standards.md)) with a static
  checker script, so the notebook-first workflow stays auditable.

## Modeling Logic

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

## Score Progression

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
baselines to richer ensemble routes while preserving Kaggle-safe inference and
submission validation.

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

## Repository Structure

```
kaggle-birdclef-2026/
├── notebooks/          # Kaggle notebooks — the executable source of truth
│   ├── support/        # Submission references and runtime probes
│   ├── archive/        # Historical score variants, preserved not edited
│   └── metadata/       # Kaggle kernel metadata per promoted notebook
├── docs/               # Numbered reports: EDA, model results, coding
│                       #   standards, calibration diagnostics, roadmap
├── scripts/            # Kaggle status helpers + notebook standards checker
└── README.md           # This file
```

This repository is intentionally **notebook-first**: Kaggle notebooks are the
executable source of truth, and `docs/` captures the analysis and decisions
behind each result. See
[docs/02_coding_standards.md](docs/02_coding_standards.md) for the full
convention set and [docs/15_post_competition_roadmap.md](docs/15_post_competition_roadmap.md)
for the project's current (archived) status.
