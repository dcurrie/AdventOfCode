
import dgraph, daryheap, tables, sets

#[ https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
1  function Dijkstra(Graph, source):
2      dist[source] ← 0                           // Initialization
3
4      create vertex set Q
5
6      for each vertex v in Graph:           
7          if v ≠ source
8              dist[v] ← INFINITY                 // Unknown distance from source to v
9          prev[v] ← UNDEFINED                    // Predecessor of v
10
11         Q.add_with_priority(v, dist[v])
12
13
14     while Q is not empty:                      // The main loop
15         u ← Q.extract_min()                    // Remove and return best vertex
16         for each neighbor v of u:              // only v that are still in Q
17             alt ← dist[u] + length(u, v) 
18             if alt < dist[v]
19                 dist[v] ← alt
20                 prev[v] ← u
21                 Q.decrease_priority(v, alt)
22
23     return dist, prev
]#

# from source node, returns distances to reachable nodes, and previous nodes in the shortrest 
# path, both indexed by node key K
#
proc dijkstra*[K, V](graph: var DGraph[K, V], source: K): (Table[K, V], Table[K, K]) =
    var dist: Table[K, V]
    var prev: Table[K, K]
    var pque = initDaryHeap[DNode[K,V]](4)

    for node in graph.allnodes: node.index = -1 # not in pque

    dist[source] = 0
    var snode = graph[source]
    snode.priority = 0
    pque.push(snode)
    while pque.len > 0:
        var u = pque.pop()
        let d = u.priority # == dist[u.key]
        for e in u.outedges():
            var v = e.to
            let alt = d + e.weight
            if not dist.hasKey(v.key) or alt < dist[v.key]:
                dist[v.key] = alt
                prev[v.key] = u.key
                v.priority = alt
                pque.decr(v)
    return (dist, prev)


when isMainModule:

    block: # https://www.techiedelight.com/single-source-shortest-paths-dijkstras-algorithm/
        var w = DGraph[int,int]()
        let _ = w.add_edges(@[(0, 1, 10), (0, 4, 3), (1, 2, 2), (1, 4, 4), (2, 3, 9),
                              (3, 2, 7), (4, 1, 1), (4, 2, 8), (4, 3, 2)])
        let (dist, prev) = w.dijkstra(0)
        doAssert(prev[4] == 0)
        doAssert(prev[1] == 4)
        doAssert(prev[2] == 1)
        doAssert(prev[3] == 4)
        doAssert(dist[0] == 0)
        doAssert(dist[1] == 4)
        doAssert(dist[2] == 6)
        doAssert(dist[3] == 5)
        doAssert(dist[4] == 3)

# bug!? can do above block or following block but not both, otherwise
# Utils/dijkstra.nim(76, 18) template/generic instantiation of `add_edges` from here
# Utils/dgraph.nim(90, 24) template/generic instantiation of `add_edge` from here
# Utils/dgraph.nim(81, 26) Error: type mismatch: got <DNode[system.int, system.float]> but expected 'DNode[system.int, system.int]'

#    block: # basic tests
#        var g = DGraph[int,float]()
#        let _ = g.add_edges(@[(3,4,3.5),(4,5,4.5)])
#        let (dist, prev) = g.dijkstra(3)
#        doAssert(dist[3] == 0.0)
#        doAssert(dist[4] == 3.5)
#        doAssert(dist[5] == 8.0)
#        doAssert(prev[5] == 4)
#        doAssert(prev[4] == 3)

    block: # basic tests
        var g = DGraph[uint,float]()
        let _ = g.add_edges(@[(3u,4u,3.5),(4u,5u,4.5)])
        let (dist, prev) = g.dijkstra(3u)
        doAssert(dist[3u] == 0.0)
        doAssert(dist[4u] == 3.5)
        doAssert(dist[5u] == 8.0)
        doAssert(prev[5u] == 4u)
        doAssert(prev[4u] == 3u)

    block: # https://brilliant.org/wiki/dijkstras-short-path-finder/
        var g = DGraph[char,int]()
        let _ = g.add_edges(@[('s','a',3),('s','c',2),('s','f',6),('a','b',6),('a','d',1),
                              ('c','d',3),('f','e',2),('b','e',1),('d','e',4),('c','a',2)])
        let (dist, prev) = g.dijkstra('s')
        doAssert(prev['e'] == 'd')
        doAssert(prev['d'] == 'a')
        doAssert(prev['b'] == 'a')
        doAssert(prev['a'] == 's')
        doAssert(prev['c'] == 's')
        doAssert(prev['f'] == 's')
        doAssert(dist['s'] == 0)
        doAssert(dist['a'] == 3)
        doAssert(dist['b'] == 9)
        doAssert(dist['c'] == 2)
        doAssert(dist['d'] == 4)
        doAssert(dist['e'] == 8)
        doAssert(dist['f'] == 6)


