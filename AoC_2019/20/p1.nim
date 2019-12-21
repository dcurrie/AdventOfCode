import strutils, sequtils, strscans, os, tables, sets, algorithm, unicode

import ../../Utils/dgraph
import ../../Utils/dijkstra
import ../../Utils/daryheap

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "in1.txt"
    input = readFile(fname)

type
    Locn = tuple[x: int, y: int]

var
    world: Table[Locn, char]
    graph: DGraph[Locn,int]
    ports: Table[(char,char), Locn]

    verbo = true

var miny = 0
var minx = 0
var maxy = 0
var maxx = 0

proc checkpath(w: var Table[Locn, char], g: var DGraph[Locn,int], c: char, x, y: int) =
    let fmkey = (x,y)
    let upkey = (x,y-1)
    let lfkey = (x-1,y)
    w[fmkey] = c
    if x > 0 and w.getOrDefault(lfkey) == '.':
        let _ = g.add_edges(@[(fmkey, lfkey, 1),(lfkey, fmkey, 1)])
    if y > 0 and w.getOrDefault(upkey) == '.':
        let _ = g.add_edges(@[(fmkey, upkey, 1),(upkey, fmkey, 1)])

proc portconn(g: var DGraph[Locn,int], p: var Table[(char,char), Locn], pname: (char,char), xykey: Locn) =
    if p.hasKey(pname):
        let pokey = p[pname]
        let _ = g.add_edges(@[(pokey, xykey, 1),(xykey, pokey, 1)])
        if verbo: echo "Connecting ", pname, pokey, xykey
    else:
        p[pname] = xykey
        if verbo: echo "Registering ", pname, xykey

proc checkport(w: var Table[Locn, char], g: var DGraph[Locn,int],
                 p: var Table[(char,char), Locn], c: char, x, y: int) =
    let fmkey = (x,y)
    let upkey = (x,y-1)
    let lfkey = (x-1,y)
    w[fmkey] = c
    if x > 0 and w.hasKey(lfkey): # w.getOrDefault(lfkey) == '.':
        let h = w[lfkey]
        if h >= 'A' and h <= 'Z':
            let llkey = (x-2,y)
            let rtkey = (x+1,y)
            if x > 1 and w.getOrDefault(llkey) == '.':
                portconn(g, p, (h,c), llkey)
            else:
                portconn(g, p, (h,c), rtkey)
    if y > 0 and w.hasKey(upkey): # w.getOrDefault(upkey) == '.':
        let h = w[upkey]
        if h >= 'A' and h <= 'Z':
            let uukey = (x,y-2)
            let dnkey = (x,y+1)
            if y > 1 and w.getOrDefault(uukey) == '.':
                portconn(g, p, (h,c), uukey)
            else:
                portconn(g, p, (h,c), dnkey)

proc readIn(input: string) =
    world = initTable[Locn, char]()
    graph = DGraph[Locn,int]()
    ports = Table[(char,char), Locn]()
    var y = 0
    for line in input.splitLines:
        if line != "":
            maxy = y
            maxx = max(maxx, line.len - 1)
            for x in 0..(line.len - 1):
                var c = line[x]
                if c == '#':
                    discard
                elif c == ' ':
                    discard
                elif c == '.':
                    checkpath(world, graph, c, x,y)
                elif c >= 'A' and c <= 'Z': 
                    checkport(world, graph, ports, c, x,y)
                else:
                    echo "readIn wtf: ", c
            y += 1

proc display_world() =
    var outstr: string
    for y in miny..maxy:
        for x in minx..maxx:
            let key = (x,y)
            var ochar = world.getOrDefault(key, '#')
            outstr.add(ochar)
        outstr.add('\n')
    echo(outstr)

proc part1(inp: string) =
    readIn(inp)
    display_world()
    let (dist, prev) = graph.dijkstra(ports[('A','A')])
    let d = dist[ports[('Z','Z')]]
    echo "Part 1, path length: ", d

part1(input)
