#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KAGGLE_CLI="${KAGGLE_CLI:-kaggle}"
export KAGGLE_CONFIG_DIR="${KAGGLE_CONFIG_DIR:-${HOME}/Downloads}"

COMPETITION="birdclef-2026"
LOG_PATH="${ROOT_DIR}/local_artifacts/final_ensemble_weight_submission_status.log"
LATEST_PATH="${ROOT_DIR}/local_artifacts/final_ensemble_weight_submission_latest.txt"

mkdir -p "${ROOT_DIR}/local_artifacts"

"${KAGGLE_CLI}" competitions submissions -c "${COMPETITION}" \
  | sed -n '1,10p' > "${LATEST_PATH}" 2>&1

{
  echo "Snapshot: $(date '+%Y-%m-%d %H:%M:%S %Z')"
  cat "${LATEST_PATH}"
  echo
} >> "${LOG_PATH}"

if ! grep -E "(diversity_025_015_960|anchor_015_010_975|perch_030_012_958|primary_020_020_960).*SubmissionStatus.PENDING" "${LATEST_PATH}" >/dev/null; then
  if command -v osascript >/dev/null 2>&1; then
    osascript -e 'display notification "The final ensemble notebook weight submissions have finished scoring. Check local_artifacts/final_ensemble_weight_submission_latest.txt." with title "Kaggle BirdCLEF"' >/dev/null 2>&1 || true
  fi
  exit 10
fi
