# Chapter 5 — Your First Connectome Analysis

You now have the pieces. Time to assemble them into a real workflow.

**Goal of this chapter:** load a connectivity matrix, characterise it with graph and topological measures, and compare against a null model.

!!! note "Verify against the API reference"
    Confirm exact function names and signatures in the [API Reference](../api/index.md) — e.g. [`network.topology`](../api/network-topology.md) and [`randomization`](../api/randomization.md).

## 5.1 Load (or build) a matrix

```python
import numpy as np
from scipy import sparse

# In a real analysis: A = sparse.load_npz("my_connectome.npz")
N = 300
rng = np.random.default_rng(42)
A = sparse.csr_matrix((rng.random((N, N)) < 0.03).astype(int))
A.setdiag(0)
print(f"{N} nodes, {A.nnz} edges, density={A.nnz / (N*(N-1)):.4f}")
```

## 5.2 Classical graph metrics

```python
import networkx as nx

G = nx.from_scipy_sparse_array(A, create_using=nx.DiGraph)

print("density:     ", nx.density(G))
print("reciprocity: ", nx.reciprocity(G))
print("transitivity:", nx.transitivity(G.to_undirected()))
```

## 5.3 Topological metrics with `connalysis`

```python
import connalysis  # placeholder

counts = connalysis.topology.simplex_counts(A)
print("simplex counts per dimension:", counts)
```

The output is a vector — entry $k$ is the number of $k$-simplices.

## 5.4 Generate a null model

```python
density = A.nnz / (N * (N - 1))
A_null = connalysis.randomization.erdos_renyi(N, density=density, directed=True)
counts_null = connalysis.topology.simplex_counts(A_null)
```

Repeat many times to get a distribution:

```python
import numpy as np

n_reps = 50
null_counts = []
for _ in range(n_reps):
    A_r = connalysis.randomization.erdos_renyi(N, density=density, directed=True)
    null_counts.append(connalysis.topology.simplex_counts(A_r))
null_counts = np.array(null_counts)  # shape: (n_reps, max_dim+1)
```

## 5.5 Compare and visualise

```python
import matplotlib.pyplot as plt

dims = np.arange(len(counts))
null_mean = null_counts.mean(axis=0)
null_std  = null_counts.std(axis=0)

plt.bar(dims - 0.2, counts, width=0.4, label="observed")
plt.bar(dims + 0.2, null_mean, width=0.4, yerr=null_std, label="ER null")
plt.xlabel("simplex dimension")
plt.ylabel("count")
plt.yscale("log")
plt.legend()
plt.show()
```

If the observed bar in dimension 2 or 3 sits clearly above the null error bar, your network is **enriched** in higher-order structure — the headline result of many connectome topology papers.

## 5.6 What to do next

You've now closed the loop: data → analysis → comparison → figure. From here:

- Swap the random matrix for **real data** — EM reconstructions, atlas tract data, simulated microcircuits.
- Try other **null models** ([distance-dependent, configuration model](../connectome-analysis/concepts.md)).
- Add **per-cell-type breakdowns** with `pandas`.
- Read the [upstream reference](https://openbraininstitute.github.io/connectome-analysis/) for advanced features (Betti numbers, communicability, neighbourhood profiles).

---

**You're done.** That's a complete end-to-end connectome analysis in Python.

If you have suggestions for what should come next in this tutorial, open an issue on the [TopNetBio repo](https://github.com/TopNetBio/topnetbio.github.io/issues).
