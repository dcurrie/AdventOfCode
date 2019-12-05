
import dgraph, daryheap, tables, sets, sequtils

#[ https://en.wikipedia.org/wiki/Topological_sorting#Algorithms

L ← Empty list that will contain the sorted nodes
while exists nodes without a permanent mark do
    select an unmarked node n
    visit(n)

function visit(node n)
    if n has a permanent mark then return
    if n has a temporary mark then stop   (not a DAG)
    mark n with a temporary mark
    for each node m with an edge from n to m do
        visit(m)
    remove temporary mark from n
    mark n with a permanent mark
    add n to head of L
]#

type Mark = enum unmarked, tempmark, permmark

# return an array of nodes topologically sorted (a topological sort or topological ordering of a 
# directed graph is a linear ordering of its vertices such that for every directed edge uv from 
# vertex u to vertex v, u comes before v in the ordering); the nodes are represented by key in 
# the result
#
proc dfssort*[K, V](graph: var DGraph[K, V]): seq[K] =
    var nodes = toSeq(graph.allnodes)
    # set index to 0 => unmarked
    var s = nodes.map(proc (n: DNode[K,V]): K = n.index = ord(Mark.unmarked); return n.key)
    var i = s.len # index into sorted result s
    #echo(i, s)
    proc visit(g: var DGraph[K, V], n: DNode[K,V]) =
        case n.index
        of ord(Mark.permmark): return
        of ord(Mark.tempmark): raise newException(ValueError, "not a DAG")
        of ord(Mark.unmarked): discard
        else: raise newException(RangeError, "malformed GNode defect")
        n.index = ord(Mark.tempmark)
        for e in outedges(g, n.key):
            visit(g, e.to)
        n.index = ord(Mark.permmark)
        i -= 1
        s[i] = n.key
    # the main loop
    for node in nodes:
        if node.index == ord(Mark.unmarked):
            visit(graph, node)
    assert(i == 0)
    result = s

when isMainModule:

    block: # https://www.techiedelight.com/single-source-shortest-paths-dijkstras-algorithm/
        var w = DGraph[int,int]()
        let _ = w.add_edges(@[(0, 1, 10), (0, 4, 3), (1, 2, 2), (1, 4, 4), (2, 3, 9),
                              (3, 2, 7), (4, 1, 1), (4, 2, 8), (4, 3, 2)])
        var caught = false
        try:
            let s = w.dfssort()
        except ValueError:
            caught = true
        doAssert(caught)
        #doAssert(s[2] == 1)

    block: # https://brilliant.org/wiki/dijkstras-short-path-finder/
        var g = DGraph[char,int]()
        let _ = g.add_edges(@[('s','a',3),('s','c',2),('s','f',6),('a','b',6),('a','d',1),
                              ('c','d',3),('f','e',2),('b','e',1),('d','e',4),('c','a',2)])
        let s = g.dfssort()
        echo s
        doAssert(s[0] == 's')
        doAssert(s[6] == 'e')


