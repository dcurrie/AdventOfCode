

import hashes, sets, tables

type 
  DEdge*[K, V] = ref object
    fm: DNode[K]
    to: DNode[K]
    index: int # for algorithms to store position
    weight: V

  DNode*[K, V] = ref object
    outedges: HashSet[DEdge[K, V]]
    inedges:  HashSet[DEdge[K, V]]
    key: K

  DGraph*[K, V] = object
    # A directed graph of nodes and directed edges
    nodes: Table[K, DNode[K, V]]

proc hash[K, V](x: DNode[K, V]): Hash =
  var h: Hash = 0
  h = h !& hash(x.key)
  result = !$h

proc hash[K, V](x: DEdge[K, V]): Hash =
  var h: Hash = 0
  h = h !& hash(x.fm)
  h = h !& hash(x.to)
  h = h !& hash(x.weight)
  result = !$h

proc number_of_nodes*[K, V](graph: DGraph[K, V]): int =
  ## Return the number of nodes of `graph`.
  result = graph.nodes.len

proc number_of_edges*[K, V](graph: DGraph[K, V]): int =
  ## Return the number of nodes of `graph`.
  result = 0
  for n in graph.nodes.values:
    result += n.outedges.len

proc new_node*[K, V](graph: var DGraph[K, V], key: K): DNode[K, V] =
  if graph.nodes.hasKey(key):
    result = graph.nodes[key]
  else:
    result = DNode[K, V](key: key)
    graph.nodes[key] = result

proc add_edge*[K, V](graph: var DGraph[K, V], fm: K, to: K, weight: V): DEdge[K, V] =
  var n1 = graph.new_node(fm)
  var n2 = graph.new_node(to)
  result = DEdge[K, V](fm: n1, to: n2, weight: weight)
  result.fm.outedges.incl(result)
  result.to.inedges.incl(result)

when isMainModule:

  block: # basic tests
    var g = DGraph[int,float]()
    doAssert(g.number_of_nodes == 0)
    doAssert(g.number_of_edges == 0)

    var e12 = g.add_edge(1, 2, 1.5)
    doAssert(g.number_of_nodes == 2)
    doAssert(g.number_of_edges == 1)

