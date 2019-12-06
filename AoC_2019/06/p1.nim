

import strutils, sequtils, strscans, os

import ../../Utils/dgraph, hashes, sets, tables

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "in1.txt"
    input = readFile(fname)

proc parsein(input: string): DGraph[string,int] =
    var g = DGraph[string,int]()
    for line in input.splitLines:
        if line != "":
            var orbit = line.split(')')
            assert(orbit.len == 2)
            discard g.add_edge(orbit[0], orbit[1], 1)
    return g

#proc indorbs (g: DGraph[string,int], node: DNode[string,int]) : int =
#    #let n = g[k]
#    result = 0
#    for e in node.outedges:
#        result += indorbs(g, e.to) #g[e.to]
##    result = if n.outdegree == 0: 0
##             else: foldl(toSeq(), a + indorbs(g, b.to), 0)

proc indorbs (node: DNode[string,int], depth: int) : int =
    result = depth
    node.index = depth
    for e in node.outedges:
        result += indorbs(e.to, depth + 1)

proc part1(input: string): int =
    var g = parsein(input)
    #echo g
    #var nodes = toSeq(g.allnodes)
    # set index to 0
    #for node in g.allnodes: node.index = 0
    var center = g["COM"]
    return indorbs(center, 0)

echo "Test 1: ", part1("COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L")
echo "Part 1: ", part1(input)

proc part2(input: string): int =
    var g = parsein(input)
    var lcadepth = -1
    var pathme: Table[string,int]

    discard indorbs(g["COM"], 0)

    let me = g["YOU"]
    let medepth = me.index

    var depth = medepth
    var n = me
    while n.indegree == 1 and depth > 0:
        assert(depth == n.index)
        pathme[n.key] = depth
        depth = depth - 1
        for e in n.inedges: n = e.fm # there's only one
    let santa = g["SAN"]
    let sandepth = santa.index
    n = santa
    depth = sandepth
    while n.indegree == 1 and depth > 0:
        assert(depth == n.index)
        if pathme.hasKey(n.key):
            lcadepth = pathme[n.key]
            break
        depth = depth - 1
        for e in n.inedges: n = e.fm # there's only one
    echo "My depth:    ", medepth
    echo "Santa depth: ", sandepth
    echo "LCA depth:   ", lcadepth
    return (medepth - lcadepth - 1) + (sandepth - lcadepth - 1)

echo "Part 2: ", part2(input)
