# Chapter 4 — Working with Graphs

A connectome *is* a graph. This chapter covers two equivalent ways to represent one in Python, and the trade-offs between them.

## 4.1 Adjacency matrix vs. edge list

**Adjacency matrix** — an $N \times N$ array with $A_{ij} = 1$ for an edge $i \to j$.

```python
import numpy as np
A = np.array([
    [0, 1, 0],
    [0, 0, 1],
    [1, 0, 0],
])
```

**Edge list** — a list of source–target pairs.

```python
edges = [(0, 1), (1, 2), (2, 0)]
```

The matrix is **convenient for linear algebra**. The edge list is **memory-efficient for sparse graphs and easy to iterate**. They are interconvertible:

```python
import numpy as np

N = 3
A = np.zeros((N, N), dtype=int)
for s, t in edges:
    A[s, t] = 1
```

## 4.2 Sparse matrices in practice

For 10⁴+ nodes always go sparse.

```python
from scipy import sparse

N = 10_000
density = 0.001
rng = np.random.default_rng(0)
mask = rng.random((N, N)) < density
A = sparse.csr_matrix(mask.astype(int))
A.setdiag(0)
print(A.nnz, "edges,", A.nnz / (N * (N - 1)), "density")
```

Common operations:

```python
A.sum(axis=0)          # in-degree per node
A.sum(axis=1)          # out-degree per node
A.T                    # transpose — reverses every edge
A @ A                  # 2-step paths
(A @ A).diagonal()     # 2-cycles per node
```

## 4.3 NetworkX for richer queries

`networkx` is slower than sparse matrices but offers many ready-made algorithms.

```python
import networkx as nx

G = nx.from_scipy_sparse_array(A, create_using=nx.DiGraph)
print(nx.density(G))
print(nx.reciprocity(G))
nx.in_degree_centrality(G)   # dict: node -> centrality
```

**Rule of thumb:** use sparse matrices for anything you can express in linear algebra. Reach for NetworkX when you need path-finding, motif enumeration, or community detection.

## 4.4 Visualising small graphs

For 50 nodes or fewer:

```python
import matplotlib.pyplot as plt
import networkx as nx

G = nx.gnp_random_graph(20, 0.15, directed=True, seed=0)
nx.draw(G, with_labels=True, node_color="#7ea4ff", arrows=True)
plt.show()
```

For larger graphs, plot **summary statistics** (degree distributions, simplex counts) rather than the graph itself — visual spaghetti is rarely informative.

## Exercises

1. Build a 5-node "feed-forward chain" $0 \to 1 \to 2 \to 3 \to 4$. Compute its in- and out-degree.
2. Add the reverse edge $4 \to 0$. What changes about reciprocity?
3. Take a random sparse 200-node graph and plot its in- and out-degree distributions side by side.

→ Continue to [Chapter 5: First Connectome Analysis](05-first-analysis.md)
