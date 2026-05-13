# Installation

`connalysis` is a Python package. It is not yet published on PyPI, so installation is from the GitHub source.

## Prerequisites

- Python **3.10 or newer**
- A C/C++ toolchain (for native dependencies on Linux/macOS this usually comes with Xcode CLT or `build-essential`)
- Optional but recommended: `git`, `uv` or `virtualenv`

## Quick install (pip)

```bash
python -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install --upgrade pip
pip install git+https://github.com/openbraininstitute/connectome-analysis.git
```

## Install with `uv` (faster)

[`uv`](https://github.com/astral-sh/uv) is a drop-in replacement for `pip` and `venv` that is significantly faster.

```bash
uv venv
source .venv/bin/activate
uv pip install git+https://github.com/openbraininstitute/connectome-analysis.git
```

## Development install

If you want to read the source, run the test suite, or contribute:

```bash
git clone https://github.com/openbraininstitute/connectome-analysis.git
cd connectome-analysis
pip install -e ".[dev]"
```

## Verify the install

```python
import connalysis
print(connalysis.__version__)
```

If that prints a version string without errors, you are ready for the [quickstart](quickstart.md).

## Troubleshooting

!!! warning "Build errors on `pip install`"
    Some dependencies compile native extensions. If installation fails:

    - **macOS**: run `xcode-select --install` once to provide a C compiler.
    - **Linux**: install `build-essential` (Debian/Ubuntu) or `gcc make` (RHEL/Fedora).
    - **Windows**: install [Microsoft C++ Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/) or use WSL.

!!! tip "Conda users"
    Create a clean env first: `conda create -n connalysis python=3.11 && conda activate connalysis`, then `pip install` inside it.
