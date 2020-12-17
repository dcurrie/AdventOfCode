import strutils, sequtils, strscans, os, sets, tables, parseutils, sugar

let
    params = commandLineParams()
    fname = if params.len > 0 : params[0] else : "input.txt"
    input = readFile(fname)

#echo("Params: ", params)

type Coord = tuple[x:int, y:int, z:int]

const neightbors =
    [(-1,-1,-1),
     (-1,-1, 0),
     (-1,-1, 1),
     (-1, 0,-1),
     (-1, 0, 0),
     (-1, 0, 1),
     (-1, 1,-1),
     (-1, 1, 0),
     ( 0, 1, 1),
     ( 0,-1,-1),
     ( 0,-1, 0),
     ( 0,-1, 1),
     ( 0, 0,-1),
     ( 0, 0, 1),
     ( 0, 1,-1),
     ( 0, 1, 0),
     ( 0, 1, 1),
     ( 1,-1,-1),
     ( 1,-1, 0),
     ( 1,-1, 1),
     ( 1, 0,-1),
     ( 1, 0, 0),
     ( 1, 0, 1),
     ( 1, 1,-1),
     ( 1, 1, 0),
     ( 1, 1, 1)
    ]

proc readIn(input: string): HashSet[Coord] =
    var y = 0
    for line in input.strip.splitLines:
        for x, c in line:
            if c == '#':
                result.incl((x,y,0))
                #echo((x,y))
        y.inc

# Doesn't work!? WHY???
#proc count_neighbors (hs: HashSet[Coord], n: Coord): int =
#    var (x,y,z) = n
#    for (dx,dy,dz) in neightbors:
#        if hs.contains((x+dx,y+dy,z+dz)):
#            result.inc
proc count_neighbors (hs: HashSet[Coord], n: Coord): int =
    var (x,y,z) = n
    for dx in -1..1:
        for dy in -1..1:
            for dz in -1..1:
                if (dx,dy,dz) != (0,0,0) and hs.contains((x+dx,y+dy,z+dz)):
                    result.inc

proc step (hs: HashSet[Coord]): HashSet[Coord] =
    var tried: HashSet[Coord]
    for n in hs:
        var c = count_neighbors(hs, n)
        if c == 2 or c == 3:
            result.incl(n)
        # is this optimization correct?: if c > 0:
        var (x,y,z) = n
        for (dx,dy,dz) in neightbors:
            var t = (x+dx,y+dy,z+dz)
            if hs.contains(t) or result.contains(t) or tried.contains(t):
                discard
            else:
                if count_neighbors(hs, t) == 3:
                    #echo("incl: ", t)
                    result.incl(t)
                else:
                    #echo("excl: ", t)
                    tried.incl(t)

proc echogrid(hs: HashSet[Coord]) =
    var minz, maxz, miny, maxy, minx, maxx: int
    for c in hs:
        minz = min(minz,c.z)
        maxz = max(maxz,c.z)
        miny = min(miny,c.y)
        maxy = max(maxy,c.y)
        minx = min(minx,c.x)
        maxx = max(maxx,c.x)
    for z in minz..maxz:
        echo("z=", z)
        for y in miny..maxy:
            var s = ""
            for x in minx..maxx:
                s.add(if hs.contains((x,y,z)): '#' else: '.')
            echo(s)
        echo("")

proc part1(input: string): int =
    var hs = readIn(input)
    #echogrid(hs)
    for i in 1..6:
        hs = step(hs)
        #echo(i, " ", hs.card)
        #echogrid(hs)
    result = hs.card

echo("Part 1 ex: ", part1(""".#.
..#
###"""))

echo("Part 1: ", part1(input))
