# Chapter 3 — Scientific Stack

Four libraries cover ~90% of what you'll do day-to-day:

| Library | Job |
|---|---|
| **NumPy** | Fast arrays and numerical operations |
| **SciPy** | Sparse matrices, statistics, optimisation, signal processing |
| **pandas** | Tabular data with labelled rows and columns |
| **matplotlib** | Plotting |

!!! note "Placeholder content"
    The snippets below are deliberately minimal. Add screenshots of plots and worked exercises as you flesh out the chapter.

## 3.1 NumPy — arrays

```python
import numpy as np

a = np.array([1, 2, 3, 4])
a.shape           # (4,)
a.dtype           # int64
a * 2             # array([2, 4, 6, 8])
a.mean()          # 2.5
```

Multi-dimensional:

```python
M = np.zeros((3, 3))
M[0, 1] = 1
M.sum(axis=0)     # column sums
```

**Why it matters for connectomes:** an adjacency matrix is a 2D array. Most analyses are linear-algebra on that array.

## 3.2 SciPy sparse matrices

Real connectivity matrices are 99.9% zeros. Storing them as a dense `np.zeros((N,N))` is wasteful — use sparse formats.

```python
from scipy import sparse

rows = [0, 1, 2]
cols = [1, 2, 0]
data = [1, 1, 1]
A = sparse.csr_matrix((data, (rows, cols)), shape=(3, 3))

A.nnz             # 3 (number of non-zeros)
A.toarray()       # dense view, for small matrices only
```

CSR (compressed sparse row) is the most common; CSC and COO are alternatives with trade-offs for different operations.

## 3.3 pandas — tables

```python
import pandas as pd

df = pd.DataFrame({
    "node_id":  [0, 1, 2, 3],
    "cell_type": ["exc", "exc", "inh", "exc"],
    "layer":     [5, 5, 2, 6],
})

df["cell_type"].value_counts()
df.groupby("layer")["node_id"].count()
```

Read a CSV in one line:

```python
df = pd.read_csv("nodes.csv")
```

## 3.4 matplotlib — plots

```python
import matplotlib.pyplot as plt
import numpy as np

degrees = np.random.poisson(lam=5, size=1000)

plt.hist(degrees, bins=30)
plt.xlabel("in-degree")
plt.ylabel("count")
plt.title("Degree distribution")
plt.show()
```

For interactive notebooks add `%matplotlib inline` (Jupyter) or `%matplotlib widget` (JupyterLab with `ipympl`).

## 3.5 Putting it together

```python
import numpy as np
import pandas as pd
from scipy import sparse
import matplotlib.pyplot as plt

# build a tiny random network
N = 100
p = 0.05
rng = np.random.default_rng(0)
A = sparse.csr_matrix((rng.random((N, N)) < p).astype(int))
A.setdiag(0)   # no self-loops

in_degree = np.asarray(A.sum(axis=0)).flatten()
out_degree = np.asarray(A.sum(axis=1)).flatten()

df = pd.DataFrame({"in": in_degree, "out": out_degree})
df.describe()

plt.scatter(df["in"], df["out"], alpha=0.5)
plt.xlabel("in-degree"); plt.ylabel("out-degree")
plt.show()
```

→ Continue to [Chapter 4: Working with Graphs](04-graphs.md)
