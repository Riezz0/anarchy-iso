#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/arch-offline-repo" && pwd)"
cd "$REPO_DIR"

shopt -s nullglob
PACKAGES=(./*.pkg.tar.zst)
(( ${#PACKAGES[@]} > 0 )) || { echo 'No package archives to index.' >&2; exit 1; }
mapfile -d '' -t PACKAGES < <(printf '%s\0' "${PACKAGES[@]}" | sort -zV)

# Always rebuild the index from scratch. repo-add appends to an existing
# database, so a leftover index would keep entries for packages that were
# replaced or removed from the directory.
rm -f -- offline_repo.db offline_repo.files \
    offline_repo.db.tar.zst offline_repo.files.tar.zst \
    offline_repo.db.sig offline_repo.files.sig

repo-add --quiet offline_repo.db.tar.zst "${PACKAGES[@]}"

if [[ ! -s offline_repo.db.tar.zst ]]; then
    echo 'repo-add did not produce a database.' >&2
    exit 1
fi
mv -f -- offline_repo.db.tar.zst offline_repo.db
if [[ -s offline_repo.files.tar.zst ]]; then
    mv -f -- offline_repo.files.tar.zst offline_repo.files
fi

printf 'Indexed %d package(s) into %s\n' "${#PACKAGES[@]}" "$REPO_DIR/offline_repo.db"
