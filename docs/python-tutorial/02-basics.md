# Chapter 2 — Python Basics

The minimum Python you need to read and write small scientific scripts. We'll skip language theory and go straight to working code.

!!! note "Placeholder content"
    Each section below has a working example and a one-line "what to remember." Expand with exercises and screenshots as the tutorial matures.

## 2.1 Variables and types

```python
n_neurons = 1000          # int
density   = 0.012         # float
name      = "Layer 5"     # str
is_directed = True        # bool
```

**Remember:** Python infers the type from the value. No `int` or `float` declaration.

## 2.2 Lists, tuples, dicts

```python
sources = [0, 1, 2, 2, 3]       # list — ordered, mutable
edge    = (3, 7)                # tuple — ordered, immutable
labels  = {"exc": 800, "inh": 200}   # dict — key → value
```

Access and mutation:

```python
sources[0]              # 0
sources.append(4)       # [0, 1, 2, 2, 3, 4]
labels["exc"]           # 800
```

## 2.3 Control flow

```python
for i in range(5):
    if i % 2 == 0:
        print(i, "even")
    else:
        print(i, "odd")
```

**Remember:** Indentation matters — 4 spaces, not tabs.

## 2.4 Functions

```python
def density(n_edges, n_nodes):
    """Edges-to-possible-edges ratio for a directed graph."""
    return n_edges / (n_nodes * (n_nodes - 1))

density(120, 100)   # 0.0121...
```

## 2.5 Comprehensions

A compact way to build a new list/dict from an old one:

```python
squares = [i * i for i in range(10)]
node_ids = {f"n{i}": i for i in range(5)}
```

## 2.6 Reading and writing files

```python
with open("notes.txt", "w") as f:
    f.write("hello\n")

with open("notes.txt") as f:
    print(f.read())
```

## 2.7 Imports

```python
import numpy as np
from scipy import sparse
```

`as np` is a convention. Stick to it — it's what every example online uses.

## Exercises

1. Write a function `is_symmetric(matrix)` that returns `True` if a 2D list is equal to its transpose.
2. Given a list of edges `[(0,1), (1,2), (2,0)]`, build a `dict` mapping each source node to a list of its targets.
3. Read in a CSV of node labels (you'll learn `pandas` for this in chapter 3 — for now use the `csv` module).

→ Continue to [Chapter 3: Scientific Stack](03-scientific-stack.md)
