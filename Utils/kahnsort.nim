
import dgraph, daryheap, tables, sets, sequtils, heapqueue

#[ https://en.wikipedia.org/wiki/Topological_sorting#Algorithms

L ← Empty list that will contain the sorted elements
S ← Set of all nodes with no incoming edge
while S is non-empty do
    remove a node n from S
    add n to tail of L
    for each node m with an edge e from n to m do
        remove edge e from the graph
        if m has no other incoming edges then
            insert m into S
if graph has edges then
    return error   (graph has at least one cycle)
else 
    return L   (a topologically sorted order)
]#

# return an array of nodes topologically sorted (a topological sort or topological ordering of a 
# directed graph is a linear ordering of its vertices such that for every directed edge uv from 
# vertex u to vertex v, u comes before v in the ordering); the nodes are represented by key in 
# the result; in the case of ties, nodes are removed from those available (set S) in
# lexocographical order of K
#
proc kahnsort*[K, V](graph: var DGraph[K, V]): seq[K] =
    #var nodes = toSeq(graph.allnodes)
    var sheap = initHeapQueue[K]() # S
    # set index to count of in edges, and collect all nodes with no incoming edges
    for n in graph.allnodes:
        let i = n.indegree()
        if i == 0:
            sheap.push(n.key)
        n.index = i
    while sheap.len > 0:
        let nk = sheap.pop()
        result.add(nk)
        for e in graph.outedges(nk):
            let m = e.to
            if m.index > 1:
                m.index -= 1
            elif m.index == 1:
                m.index = 0
                sheap.push(m.key)
            else:
                raise newException(ValueError, "not a DAG")
    if result.len != graph.number_of_nodes:
        raise newException(ValueError, "not a DAG")

when isMainModule:

    block: # https://www.techiedelight.com/single-source-shortest-paths-dijkstras-algorithm/
        var w = DGraph[int,int]()
        let _ = w.add_edges(@[(0, 1, 10), (0, 4, 3), (1, 2, 2), (1, 4, 4), (2, 3, 9),
                              (3, 2, 7), (4, 1, 1), (4, 2, 8), (4, 3, 2)])
        var caught = false
        try:
            let s = w.kahnsort()
        except ValueError:
            caught = true
        doAssert(caught)
        #doAssert(s[2] == 1)

    block: # https://brilliant.org/wiki/dijkstras-short-path-finder/
        var g = DGraph[char,int]()
        let _ = g.add_edges(@[('s','a',3),('s','c',2),('s','f',6),('a','b',6),('a','d',1),
                              ('c','d',3),('f','e',2),('b','e',1),('d','e',4),('c','a',2)])
        let s = g.kahnsort()
        echo s
        doAssert(s[0] == 's')
        doAssert(s[1] == 'c')
        doAssert(s[2] == 'a')
        doAssert(s[3] == 'b')
        doAssert(s[4] == 'd')
        doAssert(s[5] == 'f')
        doAssert(s[6] == 'e')

