#!/usr/bin/env bash
# Fetch the connalysis package source for API doc generation.
# Static-analysis only (griffe) — no build, no install.
set -euo pipefail

CONNALYSIS_REPO="${CONNALYSIS_REPO:-https://github.com/hkmoon/connectome-analysis.git}"
CONNALYSIS_REF="${CONNALYSIS_REF:-master}"
DEST="_vendor/connectome-analysis"
SUBPATH="src/connalysis"
PROVENANCE="_vendor/connalysis-provenance.txt"

echo "Fetching ${SUBPATH} from ${CONNALYSIS_REPO} @ ${CONNALYSIS_REF}"

rm -rf "${DEST}"
mkdir -p "${DEST}"

git -C "${DEST}" init -q
git -C "${DEST}" remote add origin "${CONNALYSIS_REPO}"
git -C "${DEST}" config core.sparseCheckout true
# Need the package for docs, plus pyproject.toml to read the declared version.
printf '%s\n' "${SUBPATH}/*" "pyproject.toml" > "${DEST}/.git/info/sparse-checkout"

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

# --- Capture provenance of the fetched source (for the docs footer / API page) ---
COMMIT_FULL="$(git -C "${DEST}" rev-parse HEAD)"
COMMIT_SHORT="$(git -C "${DEST}" rev-parse --short HEAD)"

VERSION="unknown"
if [ -f "${DEST}/pyproject.toml" ]; then
  # First `version = "X.Y.Z"`; tolerant of single/double quotes.
  VERSION="$(grep -m1 -E '^[[:space:]]*version[[:space:]]*=' "${DEST}/pyproject.toml" \
    | sed -E 's/.*=[[:space:]]*["'"'"']([^"'"'"']+)["'"'"'].*/\1/')"
  [ -n "${VERSION}" ] || VERSION="unknown"
fi

# Normalise repo URL to an https web base for a clickable commit link.
WEB_BASE="${CONNALYSIS_REPO%.git}"
case "${WEB_BASE}" in
  git@*) WEB_BASE="https://$(echo "${WEB_BASE}" | sed -E 's#git@([^:]+):#\1/#')" ;;
esac
COMMIT_URL="${WEB_BASE}/commit/${COMMIT_FULL}"

{
  echo "repo=${CONNALYSIS_REPO}"
  echo "ref=${CONNALYSIS_REF}"
  echo "version=${VERSION}"
  echo "commit=${COMMIT_FULL}"
  echo "commit_short=${COMMIT_SHORT}"
  echo "commit_url=${COMMIT_URL}"
} > "${PROVENANCE}"

echo "OK: $(find "${DEST}/${SUBPATH}" -name '*.py' | wc -l | tr -d ' ') python files at ${DEST}/${SUBPATH}"
echo "    provenance: connalysis ${VERSION} @ ${COMMIT_SHORT} (${CONNALYSIS_REF}) -> ${PROVENANCE}"
