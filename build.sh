#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="${SCRIPT_DIR}/work"
OUT_DIR="${SCRIPT_DIR}/out"

echo "==> Cleaning previous build artifacts..."
sudo rm -rf "${WORK_DIR}"

echo "==> Building ISO..."
sudo mkarchiso -v -w "${WORK_DIR}" -o "${OUT_DIR}" "${SCRIPT_DIR}"

echo "==> Cleaning up..."
sudo rm -rf "${WORK_DIR}"

echo "==> Build complete. Output in ${OUT_DIR}/"
