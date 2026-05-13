# Chapter 1 — Environment Setup

Your goal in this chapter: a working Python with Jupyter, isolated from anything else on your system, in which you can `import numpy` without errors.

## 1.1 Install Python

We recommend **Python 3.11 or 3.12** from [python.org](https://www.python.org/downloads/).

Verify your install:

```bash
python --version    # or python3 --version on macOS/Linux
```

You should see `Python 3.11.x` or similar.

!!! warning "Don't use the system Python"
    macOS and many Linux distros ship with an old Python used by the operating system. Don't pollute it. Install a fresh one and keep it separate.

## 1.2 Create a virtual environment

A **virtual environment** is a private folder of Python packages, isolated from every other project on your machine. Always work inside one.

```bash
mkdir my-connectome-work
cd my-connectome-work
python -m venv .venv
```

Activate it:

=== "macOS / Linux"

    ```bash
    source .venv/bin/activate
    ```

=== "Windows (PowerShell)"

    ```powershell
    .venv\Scripts\Activate.ps1
    ```

Your prompt should now show `(.venv)`. If you ever see strange `ModuleNotFoundError` messages, your first question is: **am I in the right venv?**

## 1.3 Install the scientific stack

```bash
pip install --upgrade pip
pip install numpy scipy pandas matplotlib jupyterlab networkx
```

This downloads several hundred MB the first time.

## 1.4 Start JupyterLab

```bash
jupyter lab
```

A browser tab opens. Click **Python 3** under "Notebook" to create your first notebook.

In the first cell, type:

```python
import numpy as np
np.arange(10)
```

Press <kbd>Shift</kbd>+<kbd>Enter</kbd>. You should see `array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])`. If you do — you're set.

## 1.5 Optional: install `connalysis` now

If you want to read along with the connectome-analysis examples:

```bash
pip install git+https://github.com/openbraininstitute/connectome-analysis.git
```

## Common pitfalls

| Symptom | Likely cause |
|---|---|
| `python: command not found` | Try `python3` instead. On Windows, re-install with "Add to PATH" checked. |
| `ModuleNotFoundError: No module named 'numpy'` | You're not in the venv. Activate it. |
| Jupyter opens but kernel says "No kernel" | Run `python -m ipykernel install --user --name=mywork` inside the venv. |

→ Continue to [Chapter 2: Python Basics](02-basics.md)
