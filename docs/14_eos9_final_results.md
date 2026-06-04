# EoS.9 Final Results

## 1. Summary

`14_eos9_public_ensemble_taxonomy_smoothing.ipynb` is the final archived
champion for this workspace.

| Metric | Score |
|---|---:|
| Public leaderboard | **0.950** |
| Private leaderboard | **0.941** |

The notebook adapts the reviewed public EoS.9 ensemble into the project style,
keeps only the three active inference routes, enables taxonomy smoothing, and
adds submission validation around the generated CSV.

## 2. Submitted Variants

| Version | Top-level weights | Public | Private | Role |
|---|---|---:|---:|---|
| v9 | `[0.020, 0.013, 0.967]` | **0.950** | **0.941** | Canonical final champion |
| v10 | `[0.025, 0.015, 0.960]` | **0.950** | **0.941** | Tied diversity probe |
| v11 | `[0.015, 0.010, 0.975]` | **0.950** | **0.941** | Tied anchor-heavy probe |
| v12 | `[0.030, 0.012, 0.958]` | **0.950** | **0.941** | Tied Perch probe |
| v13 | `[0.020, 0.020, 0.960]` | **0.950** | **0.941** | Tied primary probe |

All four final weight probes tied the canonical v9 score. That indicates the
large route internals and taxonomy smoothing dominated the final score more
than small top-level weight changes. The repository keeps v9 as the canonical
configuration because it was the first winning configuration and matches the
documented reference weights.

## 3. Reproduction Notes

- Kaggle kernel slug:
  `tuannm3812/birdclef-2026-eos9-public-ensemble-taxonomy`.
- Metadata file:
  `notebooks/metadata/14_eos9_public_ensemble_taxonomy_smoothing/kernel-metadata.json`.
- Output file: `submission.csv`.
- Direct CSV upload returned a Kaggle `400` response for this code competition,
  so submissions were made by pushing notebook versions and submitting the
  generated kernel output.

## 4. Archive Decision

Notebook 14 supersedes the ONNX Perch + SED temporal residual notebook as the
final leaderboard champion. Earlier notebooks remain valuable protected
baselines because they are project-owned modeling paths with clearer local
artifact control.
