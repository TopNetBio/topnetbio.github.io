# Examples

Worked examples on small, reproducible networks. Each example is meant to be copy-pasteable into a Jupyter notebook.

!!! note "Placeholder content"
    Stubs only — fill in once the corresponding notebooks exist.

## Example 1 — Cortical microcircuit motif analysis

**Question:** How does the simplex-count profile of a layer 5 microcircuit differ from an Erdős–Rényi graph of matched density?

**Data:** Synthetic 1000-neuron block with distance-dependent connection probability.

**What you'll learn:** Loading a matrix, computing simplex counts, generating a matched null.

```python
# TODO: example notebook goes here
```

---

## Example 2 — Reciprocity across cell types

**Question:** Are connections between excitatory neurons more or less likely to be reciprocated than between inhibitory neurons?

**Data:** A toy 200-neuron network with two cell-type labels.

**What you'll learn:** Slicing the adjacency matrix by node labels, computing per-group statistics.

```python
# TODO
```

---

## Example 3 — Communicability and information flow

**Question:** Which neurons are best positioned to broadcast signals across the network?

**What you'll learn:** Computing communicability scores; comparing them to in-degree and betweenness centrality.

```python
# TODO
```

---

## Adding your own example

1. Create a notebook in `notebooks/` of the repo.
2. Export to markdown and place it under `docs/connectome-analysis/examples/`.
3. Add a link here and to `nav:` in `mkdocs.yml`.
