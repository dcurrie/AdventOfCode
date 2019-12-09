
import hashes, sets, tables

type 
  DEdge*[K, V] = ref object
    fm*: DNode[K]
    to*: DNode[K]
    weight*: V

  DNode*[K, V] = ref object
    key*: K

  DGraph*[K, V] = object
    # A directed graph of nodes and directed edges
    nodes: Table[K, DNode[K, V]]

proc add_edge*[K, V](graph: var DGraph[K, V], fm: K, to: K, weight: V = V(1)): DEdge[K, V] =
  var n1 = DNode[K, V](key: fm)
  var n2 = DNode[K, V](key: to)
  result = DEdge[K, V](fm: n1, to: n2, weight: weight)

when defined(test1):

  block:
    var w = DGraph[int,int]()
    let _ = w.add_edge(0, 1, 10)
    echo w

  block:
    var g = DGraph[int,float]()
    let _ = g.add_edge(3,4,3.5)
    echo g

when defined(test2):

  block:
    var w = DGraph[int,int]()
    let _ = w.add_edge(0, 1, 10)
    echo w

  block:
    var g = DGraph[uint,float]()
    let _ = g.add_edge(3u,4u,3.5)
    echo g
