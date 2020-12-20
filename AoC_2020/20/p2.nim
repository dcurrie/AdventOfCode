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
type Ptile = tuple[top: string, right: string, bottom: string, left: string, ids: seq[int], ros: seq[int]]

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
        candidates[0].add((top,right,bot,left,@[k], @[0]))
        candidates[0].add((leftR,top,rightR,bot,@[k], @[1]))
        candidates[0].add((botR,leftR,topR,rightR,@[k], @[2]))
        candidates[0].add((right,botR,left,topR,@[k], @[3]))
        # flip horizontal, and rot90, rot180, rot270
        candidates[0].add((topR,left,botR,right,@[k], @[4]))
        candidates[0].add((rightR,topR,leftR,botR,@[k], @[5]))
        candidates[0].add((bot,rightR,top,leftR,@[k], @[6]))
        candidates[0].add((left,bot,right,top,@[k], @[7]))
        # flip vertical, and rot90, rot180, rot270 -- duplicates!
#        candidates[0].add((bot,leftR,top,rightR,@[k]))
#        candidates[0].add((right,bot,left,top,@[k]))
#        candidates[0].add((topR,right,botR,left,@[k]))
#        candidates[0].add((leftR,topR,rightR,botR,@[k]))

#
# 0 1 2 3    0   x,y => x + 4y
# 4 5 6 7
# 8 9 a b
# c d e f
#
# c 8 4 0    1   x,y => y + 4(3-x)
# d 9 5 1
# e a 6 2
# f b 7 3
#
# f e d c    2   x,y => (3-x) + 4(3-y)
# b a 9 8
# 7 6 5 4
# 3 2 1 0
#
# 3 7 b f    3   x,y => (3-y) + 4x
# 2 6 a e
# 1 5 9 d
# 0 4 8 c
#
# 3 2 1 0    4   x,y => (3-x) + 4y
# 7 6 5 4
# b a 9 8
# f e d c
#
# f b 7 3    5   x,y => (3-y) + 4(3-x)
# e a 6 2
# d 9 5 1
# c 8 4 0
#
# c d e f    6   x,y => x + 4(3-y)
# 8 9 a b
# 4 5 6 7
# 0 1 2 3
#
# 0 4 8 c    7   x,y => y + 4x
# 1 5 9 d
# 2 6 a e
# 3 7 b f

proc idx(x: int, y: int, width: int, ro: int): int =
    case ro:
    of 0: result = x + width * y
    of 1: result = y + width * ((width - 1) - x)
    of 2: result = ((width - 1) - x) + width * ((width - 1) - y)
    of 3: result = ((width - 1) - y) + width * x
    of 4: result = ((width - 1) - x) + width * y
    of 5: result = ((width - 1) - y) + width * ((width - 1) - x)
    of 6: result = x + width * ((width - 1) - y)
    of 7: result = y + width * x
    else: echo("ro? ", ro); result = -1

proc intersect(a: seq[int], b: seq[int]): bool =
    for i in a:
        if b.contains(i):
            return true
    return false

proc joinH(a: Ptile, b: Ptile): Ptile =
    result = (a.top & b.top, b.right, a.bottom & b.bottom, a.left, concat(a.ids, b.ids), concat(a.ros, b.ros))

proc joinV(a: Ptile, b: Ptile): Ptile =
    result = (a.top, a.right & b.right, b.bottom, a.left & b.left, concat(a.ids, b.ids), concat(a.ros, b.ros))

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
            #if t.left == u.right:
            #    candidates[to].add(joinH(u,t))

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
            #if t.top == u.bottom:
            #    candidates[to].add(joinV(u,t))

proc solve1(): int =
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
    #for i in 0..7:
    #    echo(candidates[10][i].ids, candidates[10][i].ros)
    var ids = candidates[10][0].ids
    result = ids[0] * ids[11] * ids[^12] * ids[^1]

# Part 1: 47213728755493
var part1_ids = @[1543, 2617, 2039, 2027, 1051, 3187, 1747, 2803, 1979, 1697, 3271, 2657,
                  2273, 3301, 1481, 2161, 2503, 1999, 1447, 1409, 2269, 3209, 2909, 3947,
                  1559, 2971, 1429, 1861, 2141, 3137, 1619, 1553, 1847, 2029, 3323, 2797,
                  2713, 3499, 3931, 1549, 1451, 1579, 3089, 1931, 3433, 3541, 2267, 3793,
                  1597, 2377, 3217, 2719, 1951, 3847, 1249, 1367, 3853, 3461, 3529, 3257,
                  2243, 1433, 2683, 2089, 1151, 1193, 2111, 2857, 3229, 1361, 1823, 3463,
                  2663, 3581, 2467, 1667, 3221, 2341, 3659, 2711, 3527, 2579, 2399, 3001,
                  2011, 2143, 3967, 2957, 2741, 1279, 1423, 3457, 1453, 1483, 1109, 2753,
                  2633, 2213, 3889, 3467, 2777, 3413, 3631, 2333, 3613, 1871, 3593, 2551,
                  2953, 2707, 2791, 2389, 3877, 2087, 1373, 3643, 2203, 1877, 2939, 1319,
                  1657, 3307, 3019, 3709, 2531, 2473, 3259, 2843, 3943, 3347, 1297, 1571,
                  2887, 3779, 3533, 2833, 2749, 1181, 3251, 1217, 2357, 3719, 2113, 3989]

var sea_monster = """                  #
#    ##    ##    ###
 #  #  #  #  #  #   """.splitLines

proc prepsm(): seq[(int,int)] =
    for ys, line in sea_monster:
        for xs, cs in line:
            if cs == '#':
                result.add((xs, ys))

var img: array[8*12*8*12,char]

proc splice() =
    var ids = candidates[10][0].ids
    var ros = candidates[10][0].ros
    # proc idx(x: int, y: int, width: int, ro: int): int =
    for iy in 0..8*12-1:
        var ty = iy div 8
        for ix in 0..8*12-1:
            var tx = ix div 8
            var t = tiles[ids[ty*12+tx]]
            var ro = ros[ty*12+tx]
            var i = idx(ix-8*tx+1, iy-8*ty+1, 10, ro)
            img[iy*8*12+ix] = t[i + (i div 10)] # i div 10 for newwlines

proc showimg() =
    for y in 0..8*12-1:
        var s = ""
        for x in 0..8*12-1:
            s.add(img[y*8*12+x])
        echo s

var sea_monster_idxs: seq[(int,int)]

proc convolve_step(yi: int, xi: int, ro: int): int =
    for pos in sea_monster_idxs:
        var (ys, xs) = pos
        if xs+xi >= 12*8:
            return 0
        if ys+yi >= 12*8:
            return 0
        var ci = img[idx(xs+xi, ys+yi, 12*8, ro)]
        if ci != '#':
            return 0
    return 1

proc part2(input: string): int =
    tiles.clear
    for i in 0..11: candidates[i] = @[]
    readIn(input)
    prep()
    result = solve1()
    echo("Part 1: ", result)
    sea_monster_idxs = prepsm()
    splice()
    showimg()
    var h = sea_monster.len # hight
    var nhash = sea_monster_idxs.len
    for ro in 0..7:
        var n = 0
        for y in 0..12*8-h:
            for x in 0..12*8-h:
                n += convolve_step(y, x, ro)
        echo("ro: ", ro, " n: ", n)
        if n > 0:
            result = img.count('#') - n * nhash

echo("Part 2: ", part2(input))
