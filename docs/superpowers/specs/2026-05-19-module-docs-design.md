# Design: Auto-generated module documentation for `connalysis`

- **Date:** 2026-05-19
- **Status:** Implemented (2026-05-19); spec body reconciled with revised decisions.
- **Author:** TopNetBio
- **Topic:** Add an auto-generated API Reference for the `connalysis` package to the TopNetBio MkDocs site, integrated with the existing guide — built with mkdocstrings (the same tool the upstream <https://openbraininstitute.github.io/connectome-analysis/> docs use), from the maintainer fork's source.

> **Note:** The "Decisions" section reflects the final, revised plan. The remaining sections were updated post-implementation to match what shipped (fork `hkmoon/connectome-analysis` @ `master`, connalysis v1.1.0, 6 modules, source-side docstring fixes). Original brainstorming proposed `openbraininstitute @ v1.1.0` with 6 modules and tag-pinning; the tag-pinning was superseded by unpinned branch tracking — see Decision #5.

## Problem

The TopNetBio site currently has a hand-written companion guide and Python
tutorial for `connectome-analysis`, but no API reference. The upstream project
auto-generates module reference pages with **mkdocstrings** from numpy-style
docstrings. We want equivalent module documentation hosted in the TopNetBio
site, woven into the existing learning material rather than standing as an
isolated reference. The `connalysis` source is expected to move into the
TopNetBio repository in the future; until then the documented source is the
maintainer fork `hkmoon/connectome-analysis` (the canonical upstream library
home remains `openbraininstitute/connectome-analysis`).

## Decisions (from brainstorming)

1. **Source of docs:** the real `connalysis` package (not stubs, not our own code).
2. **Timing:** set up the full infrastructure now; it produces real docs immediately by fetching source at build time.
3. **Coverage & placement:** all modules that exist in the chosen source under a dedicated **API Reference** tab, cross-linked both ways with the existing Connectome Analysis guide and Python tutorial (the "integrated" option). With the source decision below, that is **6 modules**: `modelling.modelling`, `randomization.randomization`, `network.{topology,classic,local,stats}` (connalysis v1.1.0 on the fork's `master`).
4. **Source acquisition:** fetch the source during the CI/build pipeline via shallow sparse checkout — *not* committed to this repo.
5. **Source repo & tracking mode (revised 2026-05-19):** build from the maintainer fork **`git@github.com:hkmoon/connectome-analysis.git`**, branch **`master`** (connalysis v1.1.0; unpinned — tracks fork fixes), *not* a pinned `openbraininstitute/connectome-analysis @ v1.1.0` tag. Reason: the published docstrings in upstream `v1.1.0` emit warnings that fail `mkdocs build --strict` (griffe param/signature drift, `mkdocs_autorefs` unresolved targets, broken relative `See Also` links). These are fixed **at source in the fork** so the strict build passes legitimately rather than by relaxing our own link safety net.

## Why this works technically

`mkdocstrings`' Python handler uses **griffe**, which performs **static
source analysis** by default. It only needs the `.py` source files on disk; it
never imports or compiles the package. Therefore:

- The docs build needs **no C/C++ toolchain**, **no CMake**, and **no
  `pip install` of `connalysis`** — even though the real package has native
  build dependencies.
- `mkdocs build --strict` stays green because every `:::` target resolves
  against the fetched source and every nav entry exists.

The only added build-time dependency is **network access to the fork
repository at the tracked branch** (`hkmoon/connectome-analysis` @ `master`).
It is unpinned by deliberate decision (#5) so source-side docstring fixes flow
through without a manual bump; reproducibility is traded for that immediacy.

## Architecture

```
GitHub Actions (deploy.yml)
  │
  ├─ scripts/fetch-connalysis.sh   # shallow sparse checkout, fork @ master branch
  │     └─> _vendor/connectome-analysis/src/connalysis/**.py   (git-ignored)
  │
  └─ mkdocs build --strict
        └─ mkdocstrings (python handler, griffe static analysis)
              paths: ["_vendor/connectome-analysis/src"]
              └─> renders docs/api/*.md  (::: connalysis.<module>)
```

## Components and changes

### New files

| Path | Purpose |
|---|---|
| `scripts/fetch-connalysis.sh` | Idempotent shallow **sparse checkout** of `src/connalysis/` from the source repo into `_vendor/connectome-analysis/`. Source/ref are two shell variables `CONNALYSIS_REPO` (default `https://github.com/hkmoon/connectome-analysis.git`) and `CONNALYSIS_REF` (default `master`). Safe to re-run; removes/refreshes `_vendor/` deterministically. |
| `docs/api/index.md` | API Reference landing page: the module map and how it relates to the guide. |
| `docs/api/modelling.md` | `::: connalysis.modelling.modelling` + one-line intro + back-link to guide. |
| `docs/api/randomization.md` | `::: connalysis.randomization.randomization` + intro + back-link. |
| `docs/api/network-topology.md` | `::: connalysis.network.topology` + intro + back-link. |
| `docs/api/network-classic.md` | `::: connalysis.network.classic` + intro + back-link. |
| `docs/api/network-local.md` | `::: connalysis.network.local` + intro + back-link. |
| `docs/api/network-stats.md` | `::: connalysis.network.stats` + intro + back-link. |

### Edited files

| Path | Change |
|---|---|
| `requirements.txt` | Add `mkdocstrings[python]>=0.24`. |
| `.gitignore` | Add `_vendor/`. |
| `mkdocs.yml` | Add `mkdocstrings` plugin with python handler options (`docstring_style: numpy`, `show_signature_annotations: true`, `show_source: true`, `show_submodules: true`, `show_root_heading: true`, `heading_level: 2`, `paths: ["_vendor/connectome-analysis/src"]`); add `watch: _vendor/connectome-analysis/src`; add the **API Reference** nav tab. |
| `.github/workflows/deploy.yml` | Add a step running `scripts/fetch-connalysis.sh` before `mkdocs build --strict`. |
| `README.md` | Document the local-dev fetch step (run the script once before `mkdocs serve`) and how to change the documented source (`CONNALYSIS_REPO`/`CONNALYSIS_REF`). |
| `docs/connectome-analysis/quickstart.md` | Link `simplex_counts` → `../api/network-topology.md`, `erdos_renyi` → `../api/randomization.md`. |
| `docs/connectome-analysis/concepts.md` | Link each concept (simplex, null model, communicability) to its module page. |
| `docs/connectome-analysis/index.md` | Add an **API Reference** row to the "Sections in this guide" table. |
| `docs/python-tutorial/05-first-analysis.md` | Replace the placeholder-API callout text with links to the real reference pages. |

### Unchanged

Theme/palette, existing tutorial chapters 1–4, `site/` ignore rule, the
Pages deployment model.

## `mkdocs.yml` plugin block (target state)

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

watch:
  - _vendor/connectome-analysis/src
```

Nav addition (after the existing "Connectome Analysis" section):

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

(connalysis v1.1.0 on the fork's `master` exposes `network.local` and
`network.stats`, so those pages and nav entries are included — 6 documented
modules total.)

## `scripts/fetch-connalysis.sh` behaviour

- Two override variables: `CONNALYSIS_REPO` (default
  `https://github.com/hkmoon/connectome-analysis.git`) and `CONNALYSIS_REF`
  (default `master`).
- Shallow (`--depth 1`) fetch of the ref with **sparse checkout** limited to
  `src/connalysis`.
- Target directory `_vendor/connectome-analysis/` is removed and recreated on
  each run so results are deterministic and the script is idempotent.
- Exits non-zero with a clear message if the ref does not exist or the network
  is unreachable, so CI fails loudly rather than building empty docs.
- Pure git + POSIX shell; no Python, no compiler.

## Error handling

| Failure | Behaviour |
|---|---|
| Ref missing on the source repo | Fetch script exits non-zero; CI fails with an explicit message naming `CONNALYSIS_REF` / `CONNALYSIS_REPO`. |
| Network unreachable in CI | Fetch script exits non-zero; CI fails (no silent empty docs). |
| Fork renames/removes a documented module on `master` | Tracking an unpinned branch (Decision #5) accepts this risk: a rename would surface as an unresolved `:::` target failing `mkdocs build --strict` in CI. Mitigation is fast feedback (red build) plus source control of the fork by the same maintainer; the fix is adjusting the affected `docs/api/*` pages + nav. |
| Contributor runs `mkdocs serve` without fetching | `mkdocstrings` errors on unresolved `:::` targets. Mitigated by documenting the one-time `scripts/fetch-connalysis.sh` run in `README.md`; script is idempotent. |

## Testing / verification

- `scripts/fetch-connalysis.sh` run locally populates
  `_vendor/connectome-analysis/src/connalysis/` with `.py` files from
  `hkmoon/connectome-analysis` @ `master`.
- `mkdocs build --strict` completes with no warnings and renders all 6 module
  pages with real API content (functions, signatures, source). Achieving zero
  warnings required fixing docstring defects **at source in the fork** (griffe
  param/signature drift, autorefs targets, broken `See Also` links) — see
  Decision #5.
- All new cross-links resolve under `--strict` (broken-link gate).
- Re-running the fetch script is idempotent (same tree, no error).

## Future: `connalysis` moves in-repo

When the real `connalysis` source is vendored into this repository:

1. Remove the fetch step from `deploy.yml`.
2. Repoint `python.paths` and `watch` from `_vendor/connectome-analysis/src`
   to the in-repo source path.
3. Remove `scripts/fetch-connalysis.sh`, the `_vendor/` gitignore entry, and
   the local-dev fetch note in `README.md`.

No nav changes, no new pages, no page rewrites. If the in-repo package adds,
removes, or renames modules relative to the fork's current `master`, the only
follow-up is adjusting the 6 `docs/api/*` page files and the matching nav
entries.

## Out of scope (YAGNI)

- Documenting `connalysis` submodules beyond the 6 the fork exposes
  (`rand_utils`, etc.) — match the fork's module surface only.
- API versioning / multi-version docs.
- Auto-bumping or pinning the source ref — tracking the fork's `master` is the
  deliberate decision (#5); changing the documented source stays a manual edit.
- Documenting any TopNetBio-authored Python code (none exists yet).
