# connalysis Module Documentation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an auto-generated, guide-integrated API Reference for the `connalysis` package to the TopNetBio MkDocs site, built from real upstream source fetched at build time.

**Architecture:** A shell script does a shallow sparse checkout of `src/connalysis/` from `openbraininstitute/connectome-analysis` at a pinned release tag into a git-ignored `_vendor/` directory. `mkdocstrings` (Python handler, griffe static analysis — no compile/import) renders six module pages from that source. The reference is cross-linked both ways with the existing guide and tutorial.

**Tech Stack:** MkDocs, Material theme, mkdocstrings[python] + griffe, git sparse-checkout, GitHub Actions.

**Reference spec:** `docs/superpowers/specs/2026-05-19-module-docs-design.md`

---

## File Structure

| File | Responsibility |
|---|---|
| `scripts/fetch-connalysis.sh` | Idempotently fetch upstream `src/connalysis/` at pinned tag into `_vendor/`. |
| `.gitignore` | Exclude `_vendor/`. |
| `requirements.txt` | Add `mkdocstrings[python]`. |
| `mkdocs.yml` | Register plugin + handler paths + watch + API Reference nav. |
| `docs/api/index.md` | API Reference landing / module map. |
| `docs/api/{modelling,randomization,network-topology,network-classic,network-local,network-stats}.md` | One `:::` directive page per module + intro + guide back-link. |
| `.github/workflows/deploy.yml` | Run fetch script before build. |
| `README.md` | Local-dev fetch instructions + tag-bump procedure. |
| `docs/connectome-analysis/{quickstart,concepts,index}.md`, `docs/python-tutorial/05-first-analysis.md` | Cross-links into the API Reference. |

---

## Task 1: Fetch script

**Files:**
- Create: `scripts/fetch-connalysis.sh`
- Modify: `.gitignore`

- [ ] **Step 1: Add `_vendor/` to `.gitignore`**

Append to `.gitignore` (after the `site/` block):

```gitignore
# Vendored upstream source for API docs (fetched at build time, never committed)
_vendor/
```

- [ ] **Step 2: Write `scripts/fetch-connalysis.sh`**

```bash
#!/usr/bin/env bash
# Fetch the connalysis package source for API doc generation.
# Static-analysis only (griffe) — no build, no install.
set -euo pipefail

CONNALYSIS_REF="${CONNALYSIS_REF:-v1.1.0}"
REPO_URL="https://github.com/openbraininstitute/connectome-analysis.git"
DEST="_vendor/connectome-analysis"
SUBPATH="src/connalysis"

echo "Fetching ${SUBPATH} from connectome-analysis @ ${CONNALYSIS_REF}"

rm -rf "${DEST}"
mkdir -p "${DEST}"

git -C "${DEST}" init -q
git -C "${DEST}" remote add origin "${REPO_URL}"
git -C "${DEST}" config core.sparseCheckout true
echo "${SUBPATH}/*" > "${DEST}/.git/info/sparse-checkout"

if ! git -C "${DEST}" fetch -q --depth 1 origin "refs/tags/${CONNALYSIS_REF}"; then
  echo "ERROR: could not fetch tag '${CONNALYSIS_REF}' from ${REPO_URL}" >&2
  echo "       Check CONNALYSIS_REF and network access." >&2
  exit 1
fi

git -C "${DEST}" checkout -q FETCH_HEAD

if [ ! -d "${DEST}/${SUBPATH}" ]; then
  echo "ERROR: ${SUBPATH} not present at tag '${CONNALYSIS_REF}'" >&2
  exit 1
fi

echo "OK: $(find "${DEST}/${SUBPATH}" -name '*.py' | wc -l | tr -d ' ') python files at ${DEST}/${SUBPATH}"
```

- [ ] **Step 3: Make it executable**

```bash
chmod +x scripts/fetch-connalysis.sh
```

- [ ] **Step 4: Run it — verify it fetches real source**

Run: `./scripts/fetch-connalysis.sh`
Expected: ends with `OK: <N> python files at _vendor/connectome-analysis/src/connalysis` where N ≥ 7.

- [ ] **Step 5: Verify idempotency**

Run: `./scripts/fetch-connalysis.sh && ./scripts/fetch-connalysis.sh`
Expected: second run succeeds identically, no error, same file count.

- [ ] **Step 6: Verify the expected modules exist**

Run: `ls _vendor/connectome-analysis/src/connalysis/network/`
Expected: includes `topology.py classic.py local.py stats.py`.
Run: `ls _vendor/connectome-analysis/src/connalysis/modelling/ _vendor/connectome-analysis/src/connalysis/randomization/`
Expected: `modelling.py` and `randomization.py` present respectively.

- [ ] **Step 7: Confirm `_vendor/` is git-ignored**

Run: `git status --porcelain`
Expected: shows `scripts/fetch-connalysis.sh` and `.gitignore`, but **no** `_vendor/` paths.

- [ ] **Step 8: Commit**

```bash
git add scripts/fetch-connalysis.sh .gitignore
git commit -m "Add connalysis source fetch script (pinned v1.1.0, gitignored)"
```

---

## Task 2: mkdocstrings dependency + plugin config

**Files:**
- Modify: `requirements.txt`
- Modify: `mkdocs.yml`

- [ ] **Step 1: Add the dependency**

In `requirements.txt`, add a line:

```
mkdocstrings[python]>=0.24
```

- [ ] **Step 2: Install it locally**

Run: `source .venv/bin/activate && pip install -r requirements.txt`
Expected: installs `mkdocstrings`, `mkdocstrings-python`, `griffe` without error.

- [ ] **Step 3: Update the `plugins:` block in `mkdocs.yml`**

Replace the existing:

```yaml
plugins:
  - search
  - tags
```

with:

```yaml
plugins:
  - search
  - tags
  - mkdocstrings:
      default_handler: python
      handlers:
        python:
          paths: ["_vendor/connectome-analysis/src"]
          options:
            docstring_style: numpy
            show_signature_annotations: true
            show_source: true
            show_submodules: true
            show_root_heading: true
            heading_level: 2
```

- [ ] **Step 4: Add a top-level `watch:` key in `mkdocs.yml`**

Add at the end of the file (top-level key, same indentation as `plugins:`):

```yaml
watch:
  - _vendor/connectome-analysis/src
```

- [ ] **Step 5: Verify config parses (no nav target yet, so build will warn — that is expected here)**

Run: `source .venv/bin/activate && mkdocs build 2>&1 | tail -5`
Expected: build completes (non-strict); no Python/YAML traceback. Plugin loads.

- [ ] **Step 6: Commit**

```bash
git add requirements.txt mkdocs.yml
git commit -m "Configure mkdocstrings python handler against vendored connalysis"
```

---

## Task 3: API Reference pages

**Files:**
- Create: `docs/api/index.md`
- Create: `docs/api/modelling.md`
- Create: `docs/api/randomization.md`
- Create: `docs/api/network-topology.md`
- Create: `docs/api/network-classic.md`
- Create: `docs/api/network-local.md`
- Create: `docs/api/network-stats.md`

- [ ] **Step 1: Create `docs/api/index.md`**

```markdown
# API Reference

Auto-generated reference for the [`connalysis`](https://github.com/openbraininstitute/connectome-analysis) package, built directly from the library's numpy-style docstrings.

!!! info "How this maps to the guide"
    These pages are the *what* (every function and signature). The [Connectome Analysis guide](../connectome-analysis/index.md) is the *why* and *how*. Concept and quickstart pages link directly into the relevant module below.

## Modules

| Module | Purpose |
|---|---|
| [Modelling](modelling.md) | Model / parametrize connectome connectivity. |
| [Randomization](randomization.md) | Generate randomized controls (null models). |
| [Network · Topology](network-topology.md) | Topologically motivated network metrics. |
| [Network · Classic](network-classic.md) | Classical graph-theoretic metrics. |
| [Network · Local](network-local.md) | Local / per-node network measures. |
| [Network · Stats](network-stats.md) | Statistical helpers for network data. |

!!! note "Source pinning"
    This reference is generated from upstream release **`v1.1.0`**. See the project README for how the pinned tag is bumped.
```

- [ ] **Step 2: Create `docs/api/modelling.md`**

```markdown
# Modelling

Functions to model or parametrize the connectivity of connectomes.

*Concepts:* see [Connectome Analysis → Concepts](../connectome-analysis/concepts.md).

::: connalysis.modelling.modelling
```

- [ ] **Step 3: Create `docs/api/randomization.md`**

```markdown
# Randomization

Functions to generate randomized controls (null models) of connectomes.

*Concepts:* see [Null model](../connectome-analysis/concepts.md#null-model).

::: connalysis.randomization.randomization
```

- [ ] **Step 4: Create `docs/api/network-topology.md`**

```markdown
# Network · Topology

Topologically motivated network metrics (simplex counts, flag complexes, and more).

*Concepts:* see [Directed simplex](../connectome-analysis/concepts.md#directed-simplex) and [Flag complex](../connectome-analysis/concepts.md#flag-complex).

::: connalysis.network.topology
```

- [ ] **Step 5: Create `docs/api/network-classic.md`**

```markdown
# Network · Classic

Classical graph-theoretic network metrics.

*Concepts:* see [Graph metrics](../connectome-analysis/concepts.md#graph-metrics).

::: connalysis.network.classic
```

- [ ] **Step 6: Create `docs/api/network-local.md`**

```markdown
# Network · Local

Local / per-node network measures.

*Concepts:* see [Graph metrics](../connectome-analysis/concepts.md#graph-metrics).

::: connalysis.network.local
```

- [ ] **Step 7: Create `docs/api/network-stats.md`**

```markdown
# Network · Stats

Statistical helpers for network data.

*Concepts:* see [Connectome Analysis → Concepts](../connectome-analysis/concepts.md).

::: connalysis.network.stats
```

- [ ] **Step 8: Commit**

```bash
git add docs/api/
git commit -m "Add API Reference pages (mkdocstrings directives per module)"
```

---

## Task 4: Wire nav + verify strict build

**Files:**
- Modify: `mkdocs.yml`

- [ ] **Step 1: Add the API Reference nav section**

In `mkdocs.yml`, in the `nav:` list, insert immediately after the `- Connectome Analysis:` block and before `- Python Tutorial:`:

```yaml
  - API Reference:
      - api/index.md
      - Modelling: api/modelling.md
      - Randomization: api/randomization.md
      - Network:
          - Topology: api/network-topology.md
          - Classic: api/network-classic.md
          - Local: api/network-local.md
          - Stats: api/network-stats.md
```

- [ ] **Step 2: Ensure source is present, then strict-build**

Run: `./scripts/fetch-connalysis.sh && source .venv/bin/activate && mkdocs build --strict 2>&1 | tail -15`
Expected: `Documentation built` with **no WARNING lines** (no unresolved refs, no missing nav targets).

- [ ] **Step 3: Verify real API content rendered**

Run: `grep -ci 'def \|class \|Parameters\|Returns' site/api/network-topology/index.html`
Expected: a count well above 0 (real signatures/docstrings present, not an empty page).

- [ ] **Step 4: Commit**

```bash
git add mkdocs.yml
git commit -m "Add API Reference to site navigation"
```

---

## Task 5: Guide & tutorial cross-links

**Files:**
- Modify: `docs/connectome-analysis/index.md`
- Modify: `docs/connectome-analysis/quickstart.md`
- Modify: `docs/connectome-analysis/concepts.md`
- Modify: `docs/python-tutorial/05-first-analysis.md`

- [ ] **Step 1: Add an API Reference row to the guide's sections table**

In `docs/connectome-analysis/index.md`, in the "Sections in this guide" table, add a final row before the closing of the table:

```markdown
| [API Reference](../api/index.md) | Auto-generated function-level reference for every module. |
```

- [ ] **Step 2: Link quickstart code to the reference**

In `docs/connectome-analysis/quickstart.md`, immediately after the section "## 3. A topological question" heading paragraph, add:

```markdown
!!! tip "API reference"
    Full signatures: [`network.topology`](../api/network-topology.md) for simplex counting, [`randomization`](../api/randomization.md) for null models.
```

- [ ] **Step 3: Link concepts to modules**

In `docs/connectome-analysis/concepts.md`, at the end of the "## Further reading" section, add:

```markdown
## API reference

Every concept above maps to a documented function — see the [API Reference](../api/index.md):
[Topology](../api/network-topology.md) ·
[Randomization](../api/randomization.md) ·
[Classic](../api/network-classic.md) ·
[Local](../api/network-local.md) ·
[Stats](../api/network-stats.md) ·
[Modelling](../api/modelling.md)
```

- [ ] **Step 4: Point the tutorial's placeholder callout at the real reference**

In `docs/python-tutorial/05-first-analysis.md`, replace the admonition block:

```markdown
!!! note "Placeholder content"
    Snippets use a likely `connalysis` API shape. Cross-check function names against the [upstream docs](https://openbraininstitute.github.io/connectome-analysis/) before relying on them.
```

with:

```markdown
!!! note "Verify against the API reference"
    Confirm exact function names and signatures in the [API Reference](../api/index.md) — e.g. [`network.topology`](../api/network-topology.md) and [`randomization`](../api/randomization.md).
```

- [ ] **Step 5: Strict-build with links resolved**

Run: `./scripts/fetch-connalysis.sh && source .venv/bin/activate && mkdocs build --strict 2>&1 | tail -10`
Expected: `Documentation built`, **no WARNING** about unresolved links/anchors.

- [ ] **Step 6: Commit**

```bash
git add docs/connectome-analysis/ docs/python-tutorial/05-first-analysis.md
git commit -m "Cross-link guide and tutorial with the API Reference"
```

---

## Task 6: CI pipeline + README

**Files:**
- Modify: `.github/workflows/deploy.yml`
- Modify: `README.md`

- [ ] **Step 1: Add the fetch step to the deploy workflow**

In `.github/workflows/deploy.yml`, in the `build` job, insert a new step **between** "Install dependencies" and "Build site":

```yaml
      - name: Fetch connalysis source for API docs
        run: ./scripts/fetch-connalysis.sh
```

- [ ] **Step 2: Document local dev + tag bump in README**

In `README.md`, replace the "## Local development" code block:

````markdown
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
mkdocs serve
```
````

with:

````markdown
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
./scripts/fetch-connalysis.sh   # one-time: fetch connalysis source for API docs
mkdocs serve
```

The API Reference is generated from `connalysis` source fetched by
`scripts/fetch-connalysis.sh` into the git-ignored `_vendor/` directory
(static analysis only — no build/compile). Re-run the script any time;
it is idempotent.

### Bumping the documented connalysis version

The pinned upstream release is the `CONNALYSIS_REF` default in
`scripts/fetch-connalysis.sh` (currently `v1.1.0`). To document a newer
release, change that default, re-run the script, run
`mkdocs build --strict`, and review the regenerated `docs/api/*` pages
(adjust the six page files / nav if upstream renamed modules).
````

- [ ] **Step 3: Validate the workflow YAML**

Run: `source .venv/bin/activate && python -c "import yaml,sys; yaml.safe_load(open('.github/workflows/deploy.yml')); print('deploy.yml OK')"`
Expected: `deploy.yml OK`.

- [ ] **Step 4: Full clean strict build (simulates CI order)**

Run: `rm -rf _vendor site && ./scripts/fetch-connalysis.sh && source .venv/bin/activate && mkdocs build --strict 2>&1 | tail -5`
Expected: `Documentation built` with no warnings, from a clean state.

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/deploy.yml README.md
git commit -m "Run connalysis fetch in CI; document local dev and tag bump"
```

---

## Task 7: Push & verify deploy

- [ ] **Step 1: Push**

```bash
git push origin main
```

- [ ] **Step 2: Watch the workflow**

Run: `gh run list --repo TopNetBio/topnetbio.github.io --limit 3`
Expected: the new "Deploy MkDocs site" run for this push reaches `completed / success`.

- [ ] **Step 3: Verify live API Reference (after Pages source is GitHub Actions)**

Run: `curl -sS -o /dev/null -w "%{http_code}\n" -L https://topnetbio.github.io/api/network-topology/`
Expected: `200`. (If the site still serves the Jekyll fallback, the one-time **Settings → Pages → Source → GitHub Actions** switch is still pending — note this to the user rather than treating it as a code failure.)

---

## Self-Review

**Spec coverage:**
- Fetch script, pinned tag `v1.1.0`, idempotent, git-ignored `_vendor/` → Task 1 ✓
- `mkdocstrings[python]` dep + handler config (`paths`, numpy, show_source/submodules/annotations) + `watch` → Task 2 ✓
- 6 module pages + `index.md`, `connalysis.*` identifiers, guide back-links → Task 3 ✓
- API Reference nav tab, strict build green, real content assertion → Task 4 ✓
- Two-way cross-links (quickstart, concepts, CA index table, tutorial ch.5) → Task 5 ✓
- CI fetch step before build; README local-dev + tag-bump docs → Task 6 ✓
- Error handling (missing tag / network) → encoded in Task 1 script (non-zero exit, explicit messages) ✓
- Future in-repo move → documented in spec; no code now (correctly out of scope for this plan) ✓

**Placeholder scan:** No TBD/TODO; every step has concrete file content or an exact command + expected output.

**Type/name consistency:** Identifier root is `connalysis.*` in every API page and matches `paths: ["_vendor/connectome-analysis/src"]`. `CONNALYSIS_REF`/`v1.1.0` consistent across script, README, and `api/index.md`. Path `_vendor/connectome-analysis/src` identical in script DEST+SUBPATH, `mkdocs.yml` `paths`/`watch`, and README.

No gaps found.
