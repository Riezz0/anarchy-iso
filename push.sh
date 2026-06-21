#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Error: not inside a git repository" >&2
    exit 1
fi

echo "==> Staging changes (excluding work/ and out/)..."
git add -A
git reset HEAD -- work/ out/ 2>/dev/null || true

if git diff --cached --quiet; then
    echo "No changes to commit."
    exit 0
fi

MSG="${1:-Update}"
echo "==> Committing: ${MSG}"
git commit -m "${MSG}"

echo "==> Pushing to origin..."
git push origin "$(git branch --show-current)"

echo "==> Done."
