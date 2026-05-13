# Quickstart

Load a connectivity matrix, ask one topological question, look at the answer. The full path in under 30 lines.

!!! note "Placeholder content"
    The snippets below show the intended shape of a quickstart. Replace function calls with the current `connalysis` API once you confirm them against the [upstream docs](https://openbraininstitute.github.io/connectome-analysis/).

## 1. A toy network

We will build a small **directed** adjacency matrix by hand. In real work, this matrix would come from EM reconstruction, tract tracing, or a network simulation.

```python
import numpy as np
from scipy import sparse

# 8 neurons, a few feed-forward and recurrent connections
rows = [0, 0, 1, 2, 2, 3, 4, 5, 6]
cols = [1, 2, 3, 3, 4, 5, 5, 6, 7]
N = 8
A = sparse.csr_matrix((np.ones(len(rows)), (rows, cols)), shape=(N, N))
```

## 2. Basic graph stats

```python
print("Number of nodes:", A.shape[0])
print("Number of edges:", A.nnz)
print("Density:        ", A.nnz / (N * (N - 1)))
```

## 3. A topological question

The smallest non-trivial topological feature of a directed network is the **directed simplex** — a chain of nodes where every earlier node connects to every later one. Counting simplices of each dimension is a structural fingerprint of the network.

```python
import connalysis  # placeholder import path

# pseudo-API — confirm exact function name in upstream docs
counts = connalysis.topology.simplex_counts(A)
print(counts)
# e.g. [8, 9, 2, 0]  -> 8 nodes, 9 edges, 2 triangles, 0 tetrahedra
```

## 4. Compare against a null model

A count is only meaningful relative to what you would expect by chance. Generate an Erdős–Rényi graph with the same density and re-count:

```python
A_null = connalysis.randomization.erdos_renyi(N, density=A.nnz / (N * (N - 1)), directed=True)
counts_null = connalysis.topology.simplex_counts(A_null)
print("observed:", counts)
print("null:    ", counts_null)
```

If the observed counts of higher-dimensional simplices exceed the null distribution, the network has **more structure** than random — a clue that whatever process generated it (development, plasticity, evolution) is non-random.

## Next steps

- Read [Concepts](concepts.md) for the maths behind simplex counts.
- See [Examples](examples.md) for richer worked cases.
- Move on to the [Python Tutorial](../python-tutorial/index.md) if any of the above felt fast.
