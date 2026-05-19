#!/usr/bin/env bash
# Fetch the connalysis package source for API doc generation.
# Static-analysis only (griffe) — no build, no install.
set -euo pipefail

CONNALYSIS_REPO="${CONNALYSIS_REPO:-https://github.com/hkmoon/connectome-analysis.git}"
CONNALYSIS_REF="${CONNALYSIS_REF:-main}"
DEST="_vendor/connectome-analysis"
SUBPATH="src/connalysis"

echo "Fetching ${SUBPATH} from ${CONNALYSIS_REPO} @ ${CONNALYSIS_REF}"

rm -rf "${DEST}"
mkdir -p "${DEST}"

git -C "${DEST}" init -q
git -C "${DEST}" remote add origin "${CONNALYSIS_REPO}"
git -C "${DEST}" config core.sparseCheckout true
echo "${SUBPATH}/*" > "${DEST}/.git/info/sparse-checkout"

if ! git -C "${DEST}" fetch -q --depth 1 origin "${CONNALYSIS_REF}"; then
  echo "ERROR: could not fetch ref '${CONNALYSIS_REF}' from ${CONNALYSIS_REPO}" >&2
  echo "       Check CONNALYSIS_REF / CONNALYSIS_REPO and network access." >&2
  exit 1
fi

git -C "${DEST}" checkout -q FETCH_HEAD

if [ ! -d "${DEST}/${SUBPATH}" ]; then
  echo "ERROR: ${SUBPATH} not present at ref '${CONNALYSIS_REF}'" >&2
  exit 1
fi

echo "OK: $(find "${DEST}/${SUBPATH}" -name '*.py' | wc -l | tr -d ' ') python files at ${DEST}/${SUBPATH}"
