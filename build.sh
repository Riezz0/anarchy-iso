#!/usr/bin/env bash
set -euo pipefail

WORK_DIR="$(pwd)/work"
OUT_DIR="$(pwd)/out"

echo "==> Cleaning previous build artifacts..."
rm -rf "${WORK_DIR}" "${OUT_DIR}"

echo "==> Building ISO..."
sudo mkarchiso -v -w "${WORK_DIR}" -o "${OUT_DIR}" "$(pwd)"

echo "==> Cleaning work directory..."
rm -rf "${WORK_DIR}"

echo "==> Build complete. Output in ${OUT_DIR}/"
