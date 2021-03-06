import strutils, sequtils, strscans, os, sets, tables, parseutils, sugar, algorithm

let
    params = commandLineParams()
    fname = if params.len > 0 : params[0] else : "input.txt"
    input = readFile(fname)

#echo("Params: ", params)

var tiles: Table[int, string]

proc readIn(input: string) =
    for tile in input.strip.split("\n\n"):
        var tileid: int
        var timage: string
        if tile.scanf("Tile $i:\n$+$.", tileid, timage):
            tiles[tileid] = timage
        else:
            echo("wtf :", tile)
            return

# possible (multi-)tile placement; all strings are LtoR, TtoB
type Ptile = tuple[top: string, right: string, bottom: string, left: string, ids: seq[int]]

# indexed by width-1, so
# candidates[0] is a list of the intial tiles in all orientations
# candidates[1] is a list of 2 tiles assembled L to R
# candidates[2] is a list of 3 tiles assembled L to R, etc.
var candidates: array[12, seq[Ptile]]

proc prep() =
    # add each combination of four edges
    for k, ts in pairs(tiles):
        var t = ts.splitLines
        var top = t[0]
        var bot = t[^1]
        var left = foldl(t, a & b[0], "")
        var right = foldl(t, a & b[^1], "")
        var topR = top.reversed.join
        var botR = bot.reversed.join
        var leftR = left.reversed.join
        var rightR = right.reversed.join
        #echo(k, "  ",top, "  ", right, "  ", bot, "  ", left)
        #echo(k, "  ",topR, "  ", rightR, "  ", botR, "  ", leftR)
        #break
        # orig, rot90, rot180, rot270
        candidates[0].add((top,right,bot,left,@[k]))
        candidates[0].add((leftR,top,rightR,bot,@[k]))
        candidates[0].add((botR,leftR,topR,rightR,@[k]))
        candidates[0].add((right,botR,left,topR,@[k]))
        # flip horizontal, and rot90, rot180, rot270
        candidates[0].add((topR,left,botR,right,@[k]))
        candidates[0].add((rightR,topR,leftR,botR,@[k]))
        candidates[0].add((bot,rightR,top,leftR,@[k]))
        candidates[0].add((left,bot,right,top,@[k]))
        # flip vertical, and rot90, rot180, rot270
        candidates[0].add((bot,leftR,top,rightR,@[k]))
        candidates[0].add((right,bot,left,top,@[k]))
        candidates[0].add((topR,right,botR,left,@[k]))
        candidates[0].add((leftR,topR,rightR,botR,@[k]))

# tp: seq of seq of four edges: orig, rot90, rot180, rot270, flipped, &rot90, &rot180, &rot270
#var tp: Table[int,seq[Ptile]]

proc intersect(a: seq[int], b: seq[int]): bool =
    for i in a:
        if b.contains(i):
            return true
    return false

proc joinH(a: Ptile, b: Ptile): Ptile =
    result = (a.top & b.top, b.right, a.bottom & b.bottom, a.left, concat(a.ids, b.ids))

proc joinV(a: Ptile, b: Ptile): Ptile =
    result = (a.top, a.right & b.right, b.bottom, a.left & b.left, concat(a.ids, b.ids))

proc dblH(fm: int, to: int) =
    for i, t in candidates[fm]:
        for j in (i+1)..candidates[fm].len-1:
            var u = candidates[fm][j]
            if intersect(t.ids, u.ids):
                continue
            if t.right == u.left:
                candidates[to].add(joinH(t,u))
            if t.left == u.right:
                candidates[to].add(joinH(u,t))

proc addH(fm1: int, fm2: int, to: int) =
    for t in candidates[fm1]:
        for u in candidates[fm2]:
            if intersect(t.ids, u.ids):
                continue
            if t.right == u.left:
                candidates[to].add(joinH(t,u))
            if t.left == u.right:
                candidates[to].add(joinH(u,t))

proc dblV(fm: int, to: int) =
    for i, t in candidates[fm]:
        for j in (i+1)..candidates[fm].len-1:
            var u = candidates[fm][j]
            if intersect(t.ids, u.ids):
                continue
            if t.bottom == u.top:
                candidates[to].add(joinV(t,u))
            if t.top == u.bottom:
                candidates[to].add(joinV(u,t))

proc addV(fm1: int, fm2: int, to: int) =
    for t in candidates[fm1]:
        for u in candidates[fm2]:
            if intersect(t.ids, u.ids):
                continue
            if t.bottom == u.top:
                candidates[to].add(joinV(t,u))
            if t.top == u.bottom:
                candidates[to].add(joinV(u,t))

proc solve(): int =
    dblH(0, 1) # 1x2 candidates -> candidates[1]
    echo("1x2 ", candidates[1].len)
    dblH(1, 3) # 1x4 candidates -> candidates[3]
    echo("1x4 ", candidates[3].len)
    dblH(3, 7) # 1x8 candidates -> candidates[7]
    echo("1x8 ", candidates[7].len)
    addH(3, 7, 11) # 1x12 candidates -> candidates[11]
    echo("1xc ", candidates[11].len)
    dblV(11, 2) # 2x12 candidates -> candidates[2]
    echo("2xc ", candidates[2].len)
    dblV(2, 4) # 4x12 candidates -> candidates[4]
    echo("4xc ", candidates[4].len)
    dblV(4, 8) # 8x12 candidates -> candidates[8]
    echo("8xc ", candidates[8].len)
    addV(4, 8, 10) # 12x12 candidates -> candidates[10]
    echo("cxc ", candidates[10].len)
    echo(candidates[10][0].ids)
    var ids = candidates[10][0].ids
    result = ids[0] * ids[11] * ids[^12] * ids[^1]

proc part1(input: string): int =
    tiles.clear
    for i in 0..11: candidates[i] = @[]
    readIn(input)
    prep()
    result = solve()

echo("Part 1: ", part1(input))
