import cProfile
import collections
import itertools
import random


# Returns labels approximating the orbits of graph. Two nodes in the same orbit
# have the same label, but two nodes in different orbits don't necessarily have
# different labels.
def invariant_labels(graph, n):
    labels = [1] * n
    for r in range(2):
        incoming = [0] * n
        outgoing = [0] * n
        for i, j in graph:
            incoming[j] += labels[i]
            outgoing[i] += labels[j]
        for i in range(n):
            labels[i] = hash((incoming[i], outgoing[i]))
    return labels


# Returns the inverse of perm.
def inverse_permutation(perm):
    n = len(perm)
    inverse = [None] * n
    for i in range(n):
        inverse[perm[i]] = i
    return inverse


# Returns the permutation that sorts by label.
def label_sorting_permutation(labels):
    n = len(labels)
    return inverse_permutation(sorted(range(n), key=lambda i: labels[i]))


# Returns the graph where node i becomes perm[i] .
def permuted_graph(perm, graph):
    perm_graph = [(perm[i], perm[j]) for (i, j) in graph]
    perm_graph.sort()
    return perm_graph


# Yields each permutation generated by swaps of two consecutive nodes with the
# same label.
def label_stabilizer(labels):
    n = len(labels)
    factors = (
        itertools.permutations(block)
        for (_, block) in itertools.groupby(range(n), key=lambda i: labels[i])
    )
    for subperms in itertools.product(*factors):
        yield [i for subperm in subperms for i in subperm]


# Returns the canonical labeled graph isomorphic to graph.
def canonical_graph(graph, n):
    labels = invariant_labels(graph, n)
    sorting_perm = label_sorting_permutation(labels)
    graph = permuted_graph(sorting_perm, graph)
    labels.sort()
    return max(
        (permuted_graph(perm, graph), perm[sorting_perm[n - 1]])
        for perm in label_stabilizer(labels)
    )


# Returns the list of permutations that stabilize graph.
def graph_stabilizer(graph, n):
    return [
        perm
        for perm in label_stabilizer(invariant_labels(graph, n))
        if permuted_graph(perm, graph) == graph
    ]


# Yields the subsets of range(n) .
def power_set(n):
    for r in range(n + 1):
        for s in itertools.combinations(range(n), r):
            yield list(s)


# Returns the set where i becomes perm[i] .
def permuted_set(perm, s):
    perm_s = [perm[i] for i in s]
    perm_s.sort()
    return perm_s


# If s is canonical, returns the list of permutations in group that stabilize s.
# Otherwise, returns None.
def set_stabilizer(s, group):
    stabilizer = []
    for perm in group:
        perm_s = permuted_set(perm, s)
        if perm_s < s:
            return None
        if perm_s == s:
            stabilizer.append(perm)
    return stabilizer


# Yields one representative of each isomorphism class.
def enumerate_graphs(n):
    assert 0 <= n
    if 0 == n:
        yield []
        return
    for subgraph in enumerate_graphs(n - 1):
        sub_stab = graph_stabilizer(subgraph, n - 1)
        for incoming in power_set(n - 1):
            in_stab = set_stabilizer(incoming, sub_stab)
            if not in_stab:
                continue
            for outgoing in power_set(n - 1):
                out_stab = set_stabilizer(outgoing, in_stab)
                if not out_stab:
                    continue
                graph, i_star = canonical_graph(
                    subgraph
                    + [(i, n - 1) for i in incoming]
                    + [(n - 1, j) for j in outgoing],
                    n,
                )
                if i_star == n - 1:
                    yield graph


def test():
    print(sum(1 for graph in enumerate_graphs(4)))


cProfile.run("test()")