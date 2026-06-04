#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHECK_SCRIPT="${ROOT_DIR}/scripts/check_notebook14_weight_submissions.sh"
WATCH_LOG="${ROOT_DIR}/local_artifacts/notebook14_weight_submission_watcher.log"

mkdir -p "${ROOT_DIR}/local_artifacts"

echo "Watcher started at $(date '+%Y-%m-%d %H:%M:%S %Z')" >> "${WATCH_LOG}"

for attempt in $(seq 1 48); do
  echo "Attempt ${attempt}/48 at $(date '+%Y-%m-%d %H:%M:%S %Z')" >> "${WATCH_LOG}"
  if "${CHECK_SCRIPT}"; then
    sleep 300
  else
    status=$?
    if [ "${status}" -eq 10 ]; then
      echo "Weight submissions left pending state at $(date '+%Y-%m-%d %H:%M:%S %Z')" >> "${WATCH_LOG}"
      exit 0
    fi
    echo "Checker failed with status ${status} at $(date '+%Y-%m-%d %H:%M:%S %Z')" >> "${WATCH_LOG}"
    exit "${status}"
  fi
done

echo "Watcher ended after 48 checks at $(date '+%Y-%m-%d %H:%M:%S %Z')" >> "${WATCH_LOG}"
