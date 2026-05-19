# Concepts

A short, plain-language tour of the ideas behind `connalysis`. No proofs — just enough vocabulary to read the API docs without getting lost.

## Connectivity matrix

The starting point is always an adjacency matrix $A$, where $A_{ij} = 1$ if neuron $i$ sends a connection to neuron $j$, and $0$ otherwise. In real connectomes $A$ is **sparse** (mostly zeros), **directed** (asymmetric), and possibly **weighted**.

## Directed simplex

A **$k$-simplex** is a set of $k+1$ nodes with a total ordering, where every earlier node connects to every later one.

- A 0-simplex is a single node.
- A 1-simplex is an edge $i \to j$.
- A 2-simplex is a directed triangle: $i \to j$, $i \to k$, $j \to k$.
- A 3-simplex (tetrahedron): four nodes, all six edges pointing "forward".

Counting how many simplices of each dimension exist in a network gives a vector of **simplex counts** — a robust structural fingerprint.

!!! tip "Why directed simplices?"
    Undirected motifs (e.g. triangles regardless of arrow direction) discard the information that biology cares about most: who is upstream of whom. Directed simplices keep that information.

## Flag complex

The collection of all directed simplices of a network forms its **directed flag complex**. From this complex you can compute classical topological invariants such as **Betti numbers**, which count "holes" of each dimension — coordinated absence of higher-order structure.

## Null model

A *null model* is a randomised version of your network that preserves some chosen properties (density, degree sequence, distance dependence) but randomises the rest. Comparing the real network to the null distribution tells you whether an observed feature is **enriched** beyond chance.

Common nulls in `connalysis`:

| Null | Preserves | Randomises |
|---|---|---|
| Erdős–Rényi | Density only | Everything else |
| Configuration model | Per-node in- and out-degree | Edge identities |
| Distance-dependent | Density vs. spatial distance | Identity of partners at each distance |

## Communicability

A weighted sum over all walks between two nodes, with longer walks weighted less. High communicability means information has many paths to flow — even if no single direct edge exists.

## Graph metrics

Beyond topology, `connalysis` exposes ordinary graph metrics:

- **Reciprocity** — fraction of edges that have a back-edge.
- **Clustering** — neighbours of a node tend to also be neighbours of each other.
- **Path length** — typical number of hops between two nodes.
- **Centrality** — how "important" a node is by various definitions.

These are the bread and butter of network science and a good sanity check before reaching for topology.

## Further reading

- Reimann et al., *Cliques of neurons bound into cavities provide a missing link between structure and function* (Frontiers in Computational Neuroscience, 2017).
- Egas Santander et al., *Efficiency and reliability in biological neural network architectures* (bioRxiv, 2024).

## API reference

Every concept above maps to a documented function — see the [API Reference](../api/index.md):
[Topology](../api/network-topology.md) ·
[Classic](../api/network-classic.md) ·
[Randomization](../api/randomization.md) ·
[Modelling](../api/modelling.md)
