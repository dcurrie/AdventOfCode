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
    graph: DGraph[(Locn,int),int]
    ports: Table[(char,char), Locn]
    conns: seq[(Locn,Locn)] # inner:outer
    names: Table[Locn,(char,char)]

    verbo = false

var miny = 0
var minx = 0
var maxy = 0
var maxx = 0

proc locntoport(pi: (Locn,int)): string =
    var rs = ""
    let (p, lvl) = pi
    let (c1,c2) = names[p]
    return rs & $c1 & $c2 & "@" & $lvl

proc isOuter(p: Locn): bool = 
    result = p.x == 2 or p.x == maxx - 2 or p.y == 2 or p.y == maxy - 2

proc checkpath(w: var Table[Locn, char], g: var DGraph[(Locn,int),int], c: char, x, y: int) =
    let fmkey = (x,y)
    let upkey = (x,y-1)
    let lfkey = (x-1,y)
    w[fmkey] = c
    if x > 0 and w.getOrDefault(lfkey) == '.':
        let _ = g.add_edges(@[((fmkey,0), (lfkey,0), 1),((lfkey,0), (fmkey,0), 1)])
    if y > 0 and w.getOrDefault(upkey) == '.':
        let _ = g.add_edges(@[((fmkey,0), (upkey,0), 1),((upkey,0), (fmkey,0), 1)])

# connect an inner edge at level fmlvl to an outer edge at level fmlvl+1
proc makeconn(g: var DGraph[(Locn,int),int], fmlvl: int, inner: Locn, outer: Locn) =
    let _ = g.add_edges(@[((inner,fmlvl),(outer,fmlvl+1),1),((outer,fmlvl+1),(inner,fmlvl),1)])
    if verbo: echo "Add edges ", locntoport((inner,fmlvl)), "↔", locntoport((outer,fmlvl+1))

proc portconn(g: var DGraph[(Locn,int),int], p: var Table[(char,char), Locn], pname: (char,char), xykey: Locn) =
    if p.hasKey(pname):
        let pokey = p[pname]
        if pokey.isOuter:
            conns.add((xykey,pokey))
        else:
            assert xykey.isOuter
            conns.add((pokey,xykey))
        if verbo: echo "Connecting ", pname, pokey, xykey
    else:
        p[pname] = xykey
        if verbo: echo "Registering ", pname, xykey
    names[xykey] = pname

proc checkport(w: var Table[Locn, char], g: var DGraph[(Locn,int),int],
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
    graph = DGraph[(Locn,int),int]()
    ports = Table[(char,char), Locn]()
    var y = 0
    let sl = input.splitLines
    for line in sl:
        if line != "":
            maxy = y
            maxx = max(maxx, line.len - 1)
            y += 1
    y = 0
    for line in sl:
        if line != "":
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
            var ochar = world.getOrDefault(key, ' ') # '#'
            outstr.add(ochar)
        outstr.add('\n')
    echo(outstr)

# returns two level graph
proc prune(): DGraph[(Locn,int),int] =
    var pg = DGraph[(Locn,int),int]()
    let (dist, _) = graph.dijkstra((ports[('A','A')],0))
    if verbo: echo "AA dist ", dist
    for (inner,outer) in conns:
        echo "Inner: ", inner, " ", locntoport((inner,0))
        echo "Outer: ", outer, " ", locntoport((outer,0))
        if dist.hasKey((inner,0)):
            let _ = pg.add_edge((ports[('A','A')],0), (inner,0), dist[(inner,0)])
            if verbo: echo "Add AA to ", locntoport((inner,0)), dist[(inner,0)]
    let (disz, _) = graph.dijkstra((ports[('Z','Z')],0))
    for (inner,_) in conns:
        if disz.hasKey((inner,0)):
            let _ = pg.add_edge((inner,0), (ports[('Z','Z')],0), disz[(inner,0)])
            if verbo: echo "Add ZZ to ", locntoport((inner,0)), disz[(inner,0)]
    for p in keys(names):
        let (dist, _) = graph.dijkstra((p,0))
        for q in keys(names):
            if p != q and dist.hasKey((q,0)):
                let _ = pg.add_edge((p,0), (q,0), dist[(q,0)])
                #let _ = pg.add_edge((outer,0), (inner,0), dist[(outer,0)])
                if verbo: echo "Add 1-d ", locntoport((p,0)), " → ", locntoport((q,0)), " ", dist[(q,0)]
#[
    for (inner,_) in conns:
        let (dist, _) = graph.dijkstra((inner,0))
        for (inne2,outer) in conns:
            if dist.hasKey((outer,0)):
                let _ = pg.add_edge((inner,0), (outer,0), dist[(outer,0)])
                let _ = pg.add_edge((outer,0), (inner,0), dist[(outer,0)])
                if verbo: echo "Add bi-d ", locntoport((inner,0)), "↔", locntoport((outer,0)), " ", dist[(outer,0)]
            if dist.hasKey((inne2,0)) and inner != inne2:
                let _ = pg.add_edge((inner,0), (inne2,0), dist[(inne2,0)])
                let _ = pg.add_edge((inne2,0), (inner,0), dist[(inne2,0)])
                if verbo: echo "Add bi-d ", locntoport((inner,0)), "↔", locntoport((inne2,0)), " ", dist[(inne2,0)]
    for (_,outer) in conns:
        let (dist, _) = graph.dijkstra((outer,0))
        for (_,oute2) in conns:
            if dist.hasKey((oute2,0)) and outer != oute2:
                let _ = pg.add_edge((outer,0), (oute2,0), dist[(oute2,0)])
                let _ = pg.add_edge((oute2,0), (outer,0), dist[(oute2,0)])
                if verbo: echo "Add bi-d ", locntoport((outer,0)), "↔", locntoport((oute2,0)), " ", dist[(oute2,0)]
]#
    for (inner,outer) in conns:
        makeconn(pg, 0, inner, outer)
    result = pg

proc inclevel(pg: var DGraph[(Locn,int),int], lvl: int) =
    for p in keys(names):
    #for (inner,outer) in conns:
        let n = pg[(p,0)]
        for e in n.outedges:
            let (fmLocn, _) = e.fm.key
            let (toLocn, v) = e.to.key
            assert fmLocn == p
            if v == 0:
                let _ = pg.add_edge((fmLocn, lvl), (toLocn, lvl), e.weight)
                #let _ = pg.add_edge((inner, lvl), (toLocn, lvl), e.weight)
                #let _ = pg.add_edge((toLocn, lvl), (inner, lvl), e.weight)
                if verbo: echo "Add 1-d ", locntoport((fmLocn, lvl)), " → ", locntoport((toLocn, lvl)), " ", e.weight
    for (inner,outer) in conns:
        makeconn(pg, lvl, inner, outer)

proc printpath(prev: Table[(Locn,int),(Locn,int)], start: (Locn,int), endnd: (Locn,int)) = 
    if endnd == start:
        echo locntoport(start)
    else:
        printpath(prev, start, prev[endnd])
        echo locntoport(endnd)

proc part2(inp: string, levels: int) =
    readIn(inp)
    display_world()
    echo names
    verbo = true
    var dmin = int.high
    var pg = prune()
    inclevel(pg, 1)
    for i in 2..levels:
        inclevel(pg, i)
        let (dist, prev) = pg.dijkstra((ports[('A','A')],0))
        #echo dist
        let d = dist.getOrDefault((ports[('Z','Z')],0), int.high)
        if d < dmin:
            dmin = d
            echo "Found ", d
            if verbo: printpath(prev, (ports[('A','A')],0), (ports[('Z','Z')],0))
        elif d == int.high:
            discard
        else:
            break
    echo "Part 2, path length: ", dmin


# add a deeper level to graph; gcopy is the original 1-level graph that we clone
# levels though fmlvl already exist
proc addlevel(gcopy: DGraph[(Locn,int),int], fmlvl: int) =
    for n in gcopy.allnodes:
        for e in n.outedges:
            let (fmLocn, _) = e.fm.key
            let (toLocn, _) = e.to.key
            let _ = graph.add_edge((fmLocn, fmlvl+1), (toLocn, fmlvl+1), e.weight)
    for (inner,outer) in conns:
        makeconn(graph, fmlvl, inner, outer)

proc part2z(inp: string, levels: int) =
    readIn(inp)
    display_world()
    let gcopy = deepCopy(graph)
    var dmin = int.high
    addlevel(gcopy, 0)
    for i in 1..levels:
        addlevel(gcopy, i)
        let (dist, _) = graph.dijkstra((ports[('A','A')],0))
        #echo dist
        let d = dist.getOrDefault((ports[('Z','Z')],0), int.high)
        if d < dmin:
            dmin = d
        elif d == int.high:
            discard
        else:
            break
    echo "Part 2, path length: ", dmin

let example2 = """
             Z L X W       C                 
             Z P Q B       K                 
  ###########.#.#.#.#######.###############  
  #...#.......#.#.......#.#.......#.#.#...#  
  ###.#.#.#.#.#.#.#.###.#.#.#######.#.#.###  
  #.#...#.#.#...#.#.#...#...#...#.#.......#  
  #.###.#######.###.###.#.###.###.#.#######  
  #...#.......#.#...#...#.............#...#  
  #.#########.#######.#.#######.#######.###  
  #...#.#    F       R I       Z    #.#.#.#  
  #.###.#    D       E C       H    #.#.#.#  
  #.#...#                           #...#.#  
  #.###.#                           #.###.#  
  #.#....OA                       WB..#.#..ZH
  #.###.#                           #.#.#.#  
CJ......#                           #.....#  
  #######                           #######  
  #.#....CK                         #......IC
  #.###.#                           #.###.#  
  #.....#                           #...#.#  
  ###.###                           #.#.#.#  
XF....#.#                         RF..#.#.#  
  #####.#                           #######  
  #......CJ                       NM..#...#  
  ###.#.#                           #.###.#  
RE....#.#                           #......RF
  ###.###        X   X       L      #.#.#.#  
  #.....#        F   Q       P      #.#.#.#  
  ###.###########.###.#######.#########.###  
  #.....#...#.....#.......#...#.....#.#...#  
  #####.#.###.#######.#######.###.###.#.#.#  
  #.......#.......#.#.#.#.#...#...#...#.#.#  
  #####.###.#####.#.#.#.#.###.###.#.###.###  
  #.......#.....#.#...#...............#...#  
  #############.#.#.###.###################  
               A O F   N                     
               A A D   M                     """

#part2(example2, 10) # 396
part2(input, 100000)
