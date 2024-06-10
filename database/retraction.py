import itertools
import numpy as np
from scipy.sparse import csr_matrix
from scipy.sparse.csgraph import shortest_path

def graph_to_csr(n, graph):
    g = np.zeros((n,n), dtype=int)
    for (x,y) in graph:
        g[x, y] = 1
    return csr_matrix(g)

def dist_matrix(n, graph):
    graph = graph_to_csr(n, graph)
    dist_matrix = shortest_path(csgraph=graph).astype(int)
    return dist_matrix

def get_retraction(n, graph, r = 1):
    out = [[i] for i in range(n)]
    inc = [[i] for i in range(n)]

    dist = dist_matrix(n, graph)

    for i in range(n):
        for j in range(n):
            if dist[i, j] <= r:
                out[i].append(j)
                inc[j].append(i)
    
    #print(out, inc)
    for e in itertools.chain(itertools.product(*[inc[i] for i in range(n)]), itertools.product(*[out[i] for i in range(n)])):
        #print(e)
        correct = True
        for d in graph:
            if dist[e[d[0]], e[d[1]]] <= 1:
                continue
            else:
                correct = False
                break
        if correct and len(set([e[j] for j in range(n)])) < n:
            return e
    return None

print(get_retraction(6, [[0,1], [1,2], [2,3], [3,4], [4,5], [5,0]], 4))
