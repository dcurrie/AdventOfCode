import strutils, sequtils, strscans, os

import ../../Utils/dgraph, hashes, sets, tables

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "in1.txt"
    input = readFile(fname)

type
    Locn = tuple[x: int, y: int]

    State = object
        world: Table[Locn, char]
        keys:  Table[char, Locn]
        doors: Table[char, Locn]
        graph: DGraph[Locn,int]
        droid: Locn

var miny = 0
var minx = 0
var maxy = 0
var maxx = 0

proc checkpath(w: var Table[Locn, char], g: var DGraph[Locn,int], c: char, x, y: int) =
    let fmkey = (x,y)
    let upkey = (x,y-1)
    let lfkey = (x-1,y)
    w[fmkey] = c
    if x > 0 and w.hasKey(lfkey): # w.getOrDefault(lfkey) == '.':
        let _ = g.add_edges(@[(fmkey, lfkey, 1),(lfkey, fmkey, 1)])
    if y > 0 and w.hasKey(upkey): # w.getOrDefault(upkey) == '.':
        let _ = g.add_edges(@[(fmkey, upkey, 1),(upkey, fmkey, 1)])

proc readIn(input: string): State =
    var world = initTable[Locn, char]()
    var keys  = initTable[char, Locn]()
    var doors = initTable[char, Locn]()
    var graph = DGraph[Locn,int]()
    var droid: Locn
    var y = 0
    for line in input.splitLines:
        if line != "":
            maxy = y
            maxx = max(maxx, line.len - 1)
            for x in 0..(line.len - 1):
                var c = line[x]
                if c == '#':
                    discard
                elif c == '.':
                    checkpath(world, graph, c, x,y)
                elif c == '@':
                    checkpath(world, graph, '.', x,y)
                    droid = (x,y)
                elif c >= 'A' and c <= 'Z': 
                    checkpath(world, graph, c, x,y)
                    doors[c] = (x,y)
                elif c >= 'a' and c <= 'z':
                    checkpath(world, graph, c, x,y)
                    keys[c] = (x,y)
                else:
                    echo "readIn wtf: ", c
            y += 1
    result = State(world: world, keys: keys, doors: doors, graph: graph, droid: droid)

proc display_world(s: State) =
    var outstr: string
    for y in miny..maxy:
        for x in minx..maxx:
            let key = (x,y)
            var ochar = s.world.getOrDefault(key, '#')
            if key == s.droid:
                ochar = '@'
            outstr.add(ochar)
        outstr.add('\n')
    echo(outstr)

# see https://github.com/jwise/aoc/blob/master/2019/18.lua

proc memoize(s: var State, 
             mem: var Table[string, (int, string)], 
             pos: Locn, 
             mykeys: HashSet[char], 
             v: (int, string)) =
    var str = $pos
    for k in s.keys.keys:
        if mykeys.contains(k):
            str = str & k
    mem[str] = v
    #echo "Memo: ", str, "=", v

proc memoized(s: var State, 
             mem: var Table[string, (int, string)], 
             pos: Locn, 
             mykeys: HashSet[char]): (int, string) =
    var str = $pos
    for k in s.keys.keys:
        if mykeys.contains(k):
            str = str & k
    if mem.hasKey(str):
        return mem[str]
    return (int.high,"")

proc availkeys(s: var State, np: Locn, passable: HashSet[char]): Table[char,(Locn,int)] =

    var keys:    Table[char,(Locn,int)]
    var visited: Table[Locn,int]
    
    proc dfs(s: var State, p: Locn, dist: int) = 
        if visited.hasKey(p) and visited[p] <= dist:
            return
        visited[p] = dist
        let c = s.world[p]
        if s.doors.hasKey(c) and not passable.contains(c.toLowerAscii):
            # we don't have the key
            return
        if s.keys.hasKey(c) and not passable.contains(c):
            keys[c] = (p, dist)
        else:
            for e in s.graph.outedges(p):
                dfs(s, e.to.key, dist + 1)
    dfs(s, np, 0)
    return keys

var shortmem: Table[string, (int, string)]

proc findPath(s: var State, p: Locn, mykeys: HashSet[char]): (int, string) =
    # do we have them all yet?
    if mykeys.len == s.keys.len:
        return (0, "")
    let (d, str) = memoized(s, shortmem, p, mykeys)
    if d < int.high:
        return (d, str)
    let options = availkeys(s, p, mykeys)
    #echo "Avail: ", options
    # try them all
    var bestdist = int.high
    var bestpdist = int.high
    var bestc: string
    for k, (np, d) in pairs(options):
        var newkeys = deepCopy(mykeys)
        newkeys.incl(k)
        var (nd, c) = findPath(s, np, newkeys)
        nd += d
        if nd < bestdist or (nd == bestdist and d < bestpdist):
            bestdist = nd
            bestpdist = d
            bestc = k & c
    memoize(s, shortmem, p, mykeys, (bestdist, bestc))
    return (bestdist, bestc)

proc part1(inp: string) =
    var s = readIn(inp)
    #display_world(s)
    let (d, p) = findPath(s, s.droid, HashSet[char]())
    echo "Part 1, path length: ", d, " path: ", p

when defined(test1):
    part1("""
#################
#i.G..c...e..H.p#
########.########
#j.A..b...f..D.o#
########@########
#k.E..a...g..B.n#
########.########
#l.F..d...h..C.m#
#################""")

    part1("""
#########
#b.A.@.a#
#########""")
    part1("""
########################
#f.D.E.e.C.b.A.@.a.B.c.#
######################.#
#d.....................#
########################
""")
    part1("""
########################
#...............b.C.D.f#
#.######################
#.....@.a.B.c.d.A.e.F.g#
########################""")
    part1("""
########################
#@..............ac.GI.b#
###d#e#f################
###A#B#C################
###g#h#i################
########################""")

part1(input)
