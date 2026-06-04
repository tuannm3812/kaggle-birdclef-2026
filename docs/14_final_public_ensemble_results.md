# Final Public Ensemble Results

## 1. Summary

`06_final_public_ensemble_taxonomy_smoothing.ipynb` is the final archived
leaderboard champion for this workspace.

| Metric | Score |
|---|---:|
| Public leaderboard | **0.950** |
| Private leaderboard | **0.941** |

The notebook adapts the reviewed public reference
`nina2025/birdclef-2026-eos-9` into the project style, keeps only the three
selected inference routes, enables taxonomy smoothing, and adds submission
validation around the generated CSV.

## 2. Submitted Variants

| Version | Top-level weights | Public | Private | Role |
|---|---|---:|---:|---|
| Version 9 | `[0.020, 0.013, 0.967]` | **0.950** | **0.941** | Canonical final champion |
| Version 10 | `[0.025, 0.015, 0.960]` | **0.950** | **0.941** | Tied diversity probe |
| Version 11 | `[0.015, 0.010, 0.975]` | **0.950** | **0.941** | Tied anchor-heavy probe |
| Version 12 | `[0.030, 0.012, 0.958]` | **0.950** | **0.941** | Tied Perch probe |
| Version 13 | `[0.020, 0.020, 0.960]` | **0.950** | **0.941** | Tied primary probe |

All four final weight probes tied the canonical version 9 score. That indicates
the large route internals and taxonomy smoothing dominated the final score more
than small top-level weight changes. The repository keeps version 9 as the
canonical configuration because it was the first winning configuration and
matches the documented reference weights.

## 3. Reproduction Notes

- Kaggle kernel slug:
  `tuannm3812/birdclef-2026-eos9-public-ensemble-taxonomy`.
- Metadata file:
  `notebooks/metadata/06_final_public_ensemble_taxonomy_smoothing/kernel-metadata.json`.
- Output file: `submission.csv`.
- Direct CSV upload returned a Kaggle `400` response for this code competition,
  so submissions were made by pushing notebook versions and submitting the
  generated kernel output.

## 4. Archive Decision

The final ensemble notebook supersedes the ONNX Perch + SED temporal residual
notebook as the final leaderboard champion. Earlier notebooks remain valuable
protected baselines because they are project-owned modeling paths with clearer
local artifact control.
