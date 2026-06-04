#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KAGGLE_CLI="${KAGGLE_CLI:-kaggle}"
export KAGGLE_CONFIG_DIR="${KAGGLE_CONFIG_DIR:-${HOME}/Downloads}"

COMPETITION="birdclef-2026"
LOG_PATH="${ROOT_DIR}/local_artifacts/notebook14_submission_status.log"
LATEST_PATH="${ROOT_DIR}/local_artifacts/notebook14_submission_latest.txt"

mkdir -p "${ROOT_DIR}/local_artifacts"

{
  echo "Snapshot: $(date '+%Y-%m-%d %H:%M:%S %Z')"
  "${KAGGLE_CLI}" competitions submissions -c "${COMPETITION}" | sed -n '1,8p'
  echo
} >> "${LOG_PATH}" 2>&1

"${KAGGLE_CLI}" competitions submissions -c "${COMPETITION}" \
  | sed -n '1,8p' > "${LATEST_PATH}" 2>&1

if ! grep -q "Notebook 14 EoS9 public ensemble taxonomy smoothing v9.*SubmissionStatus.PENDING" "${LATEST_PATH}"; then
  if command -v osascript >/dev/null 2>&1; then
    osascript -e 'display notification "Notebook 14 submission is no longer pending. Check local_artifacts/notebook14_submission_latest.txt." with title "Kaggle BirdCLEF"' >/dev/null 2>&1 || true
  fi
  exit 10
fi
