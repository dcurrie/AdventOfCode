

import hashes, sets, tables # sequtils, 

type 
  DEdge*[K, V] = ref object
    fm*: DNode[K]
    to*: DNode[K]
    weight*: V

  DNode*[K, V] = ref object
    key*: K
    outedges: HashSet[DEdge[K, V]]
    inedges:  HashSet[DEdge[K, V]]
    priority*: V # for algorithms to sort upon
    index*: int  # for algorithms to store sort position

  DGraph*[K, V] = object
    # A directed graph of nodes and directed edges
    nodes: Table[K, DNode[K, V]]

proc hash*[K, V](x: DNode[K, V]): Hash =
  var h: Hash = 0
  h = h !& hash(x.key)
  result = !$h

proc hash*[K, V](x: DEdge[K, V]): Hash =
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

iterator allnodes*[K, V](graph: DGraph[K, V]): DNode[K, V] =
  for n in graph.nodes.values:
    yield n

iterator outedges*[K, V](graph: DGraph[K, V]): DEdge[K, V] =
  for n in graph.nodes.values:
    for e in n.outedges:
      yield e

iterator outedges*[K, V](graph: DGraph[K, V], key: K): DEdge[K, V] =
  for e in graph.nodes[key].outedges:
    yield e

iterator outedges*[K, V](node: DNode[K, V]): DEdge[K, V] =
  for e in node.outedges:
    yield e

iterator inedges*[K, V](graph: DGraph[K, V], key: K): DEdge[K, V] =
  for e in graph.nodes[key].inedges:
    yield e

proc indegree*[K, V](node: DNode[K, V]): int =
  return node.inedges.len

proc indegree*[K, V](graph: DGraph[K, V], key: K): int =
  return graph.nodes[key].inedges.len

proc outdegree*[K, V](node: DNode[K, V]): int =
  return node.outedges.len

proc outdegree*[K, V](graph: DGraph[K, V], key: K): int =
  return graph.nodes[key].outedges.len

proc add_node*[K, V](graph: var DGraph[K, V], key: K): DNode[K, V] =
  if graph.nodes.hasKey(key):
    result = graph.nodes[key]
  else:
    result = DNode[K, V](key: key)
    graph.nodes[key] = result

proc add_nodes*[K, V](graph: var DGraph[K, V], nodes: seq[K]): seq[DNode[K, V]] =
  for x in nodes:
    result.add(add_node(graph, x))

proc add_edge*[K, V](graph: var DGraph[K, V], fm: K, to: K, weight: V = V(1)): DEdge[K, V] =
  var n1 = graph.add_node(fm)
  var n2 = graph.add_node(to)
  result = DEdge[K, V](fm: n1, to: n2, weight: weight)
  result.fm.outedges.incl(result)
  result.to.inedges.incl(result)

proc add_edges*[K, V](graph: var DGraph[K, V], edges: seq[(K,K,V,)]): seq[DEdge[K, V]] =
  # Error: 'graph' is of type <var DGraph[system.int, system.float]> which cannot
  # be captured as it would violate memory safety
  # edges.map(proc (x: (K,K,V,)): DEdge[K, V] = add_edge(graph, x[0], x[1], x[2]))
  for (n1, n2, w) in edges:
    result.add(add_edge(graph, n1, n2, w))

# for algos such as daryheap and dijkstra
#

proc `<`*(a, b: DNode): bool = a.priority < b.priority

proc `index=`*(x: var DNode, value: int) {.inline.} =
    x.index = value

proc `[]`*[K, V](graph: DGraph[K, V], key: K): DNode[K, V] = graph.nodes[key]


when isMainModule:

  block: # basic tests
    var g = DGraph[int,float]()
    doAssert(g.number_of_nodes == 0)
    doAssert(g.number_of_edges == 0)

    var e12 = g.add_edge(1, 2, 1.5)
    doAssert(e12.weight == 1.5)
    doAssert(g.number_of_nodes == 2)
    doAssert(g.number_of_edges == 1)

    let es = g.add_edges(@[(3,4,3.5),(4,5,4.5)])
    doAssert(es.len == 2)
    doAssert(g.number_of_nodes == 5)
    doAssert(g.number_of_edges == 3)

    let n7 = g.add_node(7)
    doAssert(n7.key == 7)
    doAssert(n7.priority == 0)
    let n5 = g.add_node(5)
    doAssert(n5.key == 5)
    doAssert(g.number_of_nodes == 6)
    doAssert(g.number_of_edges == 3)

    let ns = g.add_nodes(@[9,8,7])
    doAssert(ns.len == 3)
    doAssert(ns[1].key == 8)
    doAssert(g.number_of_nodes == 8)
    doAssert(g.number_of_edges == 3)

    var qe = 0
    for e in g.outedges:
      qe += 1
    doAssert(g.number_of_edges == qe)

    var qeo = 0
    for n in g.allnodes:
      for e in g.outedges(n.key):
        qeo += 1
    var qei = 0
    for n in g.allnodes:
      for e in g.inedges(n.key):
        qei += 1
    doAssert(qeo == qe)
    doAssert(qei == qe)

    doAssert(g.outdegree(9) == 0)
    doAssert(g.outdegree(3) == 1)
    doAssert(g.indegree(5) == 1)
