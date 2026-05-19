# Design: Auto-generated module documentation for `connalysis`

- **Date:** 2026-05-19
- **Status:** Approved (pending written-spec review)
- **Author:** TopNetBio
- **Topic:** Add an auto-generated API Reference for the `connalysis` package to the TopNetBio MkDocs site, mirroring and integrating with the existing guide — built the same way as the upstream <https://openbraininstitute.github.io/connectome-analysis/> docs (mkdocstrings).

## Problem

The TopNetBio site currently has a hand-written companion guide and Python
tutorial for `connectome-analysis`, but no API reference. The upstream project
auto-generates module reference pages with **mkdocstrings** from numpy-style
docstrings. We want equivalent module documentation hosted in the TopNetBio
site, woven into the existing learning material rather than standing as an
isolated reference. The `connalysis` source is expected to move into the
TopNetBio repository in the future; until then it lives at
`openbraininstitute/connectome-analysis`.

## Decisions (from brainstorming)

1. **Source of docs:** the real `connalysis` package (not stubs, not our own code).
2. **Timing:** set up the full infrastructure now; it produces real docs immediately by fetching upstream source at build time.
3. **Coverage & placement:** full coverage of all 6 upstream modules under a dedicated **API Reference** tab, cross-linked both ways with the existing Connectome Analysis guide and Python tutorial (the "integrated" option).
4. **Source acquisition:** fetch real upstream source during the CI/build pipeline via shallow sparse checkout — *not* committed to this repo.
5. **Upstream tracking mode:** pin to a **release tag**. Initial pin: `v1.1.0` (latest upstream release at design time).

## Why this works technically

`mkdocstrings`' Python handler uses **griffe**, which performs **static
source analysis** by default. It only needs the `.py` source files on disk; it
never imports or compiles the package. Therefore:

- The docs build needs **no C/C++ toolchain**, **no CMake**, and **no
  `pip install` of `connalysis`** — even though the real package has native
  build dependencies.
- `mkdocs build --strict` stays green because every `:::` target resolves
  against the fetched source and every nav entry exists.

The only added build-time dependency is **network access to the upstream
repository at the pinned tag**, which is reproducible and controlled.

## Architecture

```
GitHub Actions (deploy.yml)
  │
  ├─ scripts/fetch-connalysis.sh   # shallow sparse checkout @ pinned tag
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
| `scripts/fetch-connalysis.sh` | Idempotent shallow **sparse checkout** of `src/connalysis/` from `openbraininstitute/connectome-analysis` at the pinned ref into `_vendor/connectome-analysis/`. Pinned ref lives in one shell variable `CONNALYSIS_REF` (initial value `v1.1.0`). Safe to re-run; removes/refreshes `_vendor/` deterministically. |
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
| `README.md` | Document the local-dev fetch step (run the script once before `mkdocs serve`) and how to bump the pinned tag. |
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

## `scripts/fetch-connalysis.sh` behaviour

- Single pinned variable: `CONNALYSIS_REF="v1.1.0"`.
- Shallow (`--depth 1`) clone of the tag with **sparse checkout** limited to
  `src/connalysis`.
- Target directory `_vendor/connectome-analysis/` is removed and recreated on
  each run so results are deterministic and the script is idempotent.
- Exits non-zero with a clear message if the ref does not exist or the network
  is unreachable, so CI fails loudly rather than building empty docs.
- Pure git + POSIX shell; no Python, no compiler.

## Error handling

| Failure | Behaviour |
|---|---|
| Pinned tag missing upstream | Fetch script exits non-zero; CI fails with explicit message naming `CONNALYSIS_REF`. |
| Network unreachable in CI | Fetch script exits non-zero; CI fails (no silent empty docs). |
| Upstream renamed/removed a module at the pinned tag | Cannot happen for a fixed tag — pinning is precisely the mitigation. Only relevant when the tag is bumped; bumping is a deliberate change reviewed via the affected `docs/api/*` pages. |
| Contributor runs `mkdocs serve` without fetching | `mkdocstrings` errors on unresolved `:::` targets. Mitigated by documenting the one-time `scripts/fetch-connalysis.sh` run in `README.md`; script is idempotent. |

## Testing / verification

- `scripts/fetch-connalysis.sh` run locally populates
  `_vendor/connectome-analysis/src/connalysis/` with `.py` files at tag
  `v1.1.0`.
- `mkdocs build --strict` completes with no warnings and renders all 6 module
  pages with real API content (functions, signatures, source).
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
removes, or renames modules relative to `v1.1.0`, the only follow-up is
adjusting the 6 `docs/api/*` page files and the matching nav entries.

## Out of scope (YAGNI)

- Documenting `connalysis` submodules not exposed in the upstream nav
  (`rand_utils`, etc.) — match upstream's 6-module surface only.
- API versioning / multi-version docs.
- Auto-bumping the pinned tag (Dependabot-style) — bumping stays a deliberate manual edit.
- Documenting any TopNetBio-authored Python code (none exists yet).
