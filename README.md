# topnetbio.github.io

Source for the **TopNetBio** documentation site — a companion portal for the [`connectome-analysis`](https://github.com/openbraininstitute/connectome-analysis) library plus an introductory Python tutorial.

Live site: <https://topnetbio.github.io/>

## Stack

- [MkDocs](https://www.mkdocs.org/) with the [Material](https://squidfunk.github.io/mkdocs-material/) theme
- Built and deployed by **GitHub Actions** (`.github/workflows/deploy.yml`)

## Local development

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
./scripts/fetch-connalysis.sh   # one-time: fetch connalysis source for API docs
mkdocs serve
```

Then open <http://127.0.0.1:8000>. Pages live-reload on save.

The API Reference is generated from `connalysis` source fetched by
`scripts/fetch-connalysis.sh` into the git-ignored `_vendor/` directory
(static analysis only — no build/compile). Re-run the script any time;
it is idempotent.

### Changing the documented connalysis source

The documented source defaults to the maintainer fork
[`hkmoon/connectome-analysis`](https://github.com/hkmoon/connectome-analysis)
on branch `main`, set via `CONNALYSIS_REPO` / `CONNALYSIS_REF` in
`scripts/fetch-connalysis.sh`. To document a different repo or ref, change
those defaults (or export the env vars), re-run the script, run
`mkdocs build --strict`, and review the regenerated `docs/api/*` pages
(adjust the page files / nav if the module set changed).

To build a static copy:

```bash
mkdocs build --strict
# output in ./site
```

`--strict` fails on broken links and missing nav targets — the same check CI runs.

## Project layout

```
.
├── mkdocs.yml                       # Site config, theme, nav
├── requirements.txt                 # Build dependencies
├── docs/
│   ├── index.md                     # Landing page
│   ├── about.md
│   ├── connectome-analysis/         # Companion guide to connalysis
│   │   ├── index.md
│   │   ├── installation.md
│   │   ├── quickstart.md
│   │   ├── concepts.md
│   │   ├── examples.md
│   │   └── upstream.md
│   └── python-tutorial/             # 5-chapter intro tutorial
│       ├── index.md
│       └── 01-setup.md … 05-first-analysis.md
└── .github/workflows/deploy.yml     # Build + deploy to GitHub Pages
```

## Deploying

Pushes to `main` trigger the deploy workflow. **One manual step is required the first time:**

1. Repo → **Settings → Pages**
2. Under **Build and deployment → Source**, choose **GitHub Actions**

After that, every push to `main` rebuilds and publishes automatically. The workflow has no other dependencies.

## Contributing

- Edit Markdown under `docs/`.
- For a new section, add a folder + `index.md` and register it in `mkdocs.yml` under `nav:`.
- Keep links relative within `docs/` so `--strict` builds catch broken refs.

## License

Documentation: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Code snippets: MIT.
