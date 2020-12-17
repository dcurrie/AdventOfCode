import strutils, sequtils, strscans, os, sets, tables, parseutils, sugar

let
    params = commandLineParams()
    fname = if params.len > 0 : params[0] else : "input.txt"
    input = readFile(fname)

type Coord = tuple[x:int, y:int, z:int, w:int]

proc readIn(input: string): HashSet[Coord] =
    var y = 0
    for line in input.strip.splitLines:
        for x, c in line:
            if c == '#':
                result.incl((x,y,0,0))
                #echo((x,y))
        y.inc

proc count_neighbors (hs: HashSet[Coord], n: Coord): int =
    var (x,y,z,w) = n
    for dx in -1..1:
        for dy in -1..1:
            for dz in -1..1:
                for dw in -1..1:
                    if (dx,dy,dz,dw) != (0,0,0,0) and hs.contains((x+dx,y+dy,z+dz,w+dw)):
                        result.inc

proc step (hs: HashSet[Coord]): HashSet[Coord] =
    var tried: HashSet[Coord]
    for n in hs:
        var c = count_neighbors(hs, n)
        if c == 2 or c == 3:
            result.incl(n)
        var (x,y,z,w) = n
        for dx in -1..1:
            for dy in -1..1:
                for dz in -1..1:
                    for dw in -1..1:
                        var t = (x+dx,y+dy,z+dz,w+dw)
                        if hs.contains(t) or result.contains(t) or tried.contains(t):
                            discard
                        else:
                            if count_neighbors(hs, t) == 3:
                                #echo("incl: ", t)
                                result.incl(t)
                            else:
                                #echo("excl: ", t)
                                tried.incl(t)

proc part2(input: string): int =
    var hs = readIn(input)
    for i in 1..6:
        hs = step(hs)
    result = hs.card

echo("Part 2 ex: ", part2(""".#.
..#
###"""))

echo("Part 2: ", part2(input))
