
import strutils, sequtils, strscans, os, tables, sets, algorithm, unicode


#input = readFile(fname).splitLines


proc readEris(input: string): int =
    var n = 0
    for line in input.splitLines:
        if line != "":
            for c in line:
                result = result shr 1
                if c == '#':
                    result = result or 0b01000000000000000000000000
                elif c == '.':
                    discard
                else:
                    echo "Wtf: ", c
                inc n
    assert n == 25

proc drawEris(ni: int) =
    var n = ni
    for y in 1..5:
        for x in 1..5:
            stdout.write(if (n and 1) == 1: '#' else: '.')
            n = n shr 1
        stdout.write('\n')
    stdout.write('\n')

proc getBug(n, x, y: int): int =
    if x < 0 or x > 4 or y < 0 or y > 4: 0
    else: (n shr (x + y * 5)) and 1

proc countAdjacent(n, x, y: int): int =
    result = getBug(n, x-1, y) + getBug(n, x+1, y) + getBug(n, x, y-1) + getBug(n, x, y+1)

proc stepEris(ni: int): int = 
    const pb = 1 shl 24 # the bug pos in result
    var n = ni # copy input
    for y in 0..4:
        for x in 0..4:
            result = result shr 1
            let nb = countAdjacent(ni, x, y)
            #echo "nb ", (x, y, nb)
            if (n and 1) == 1 and nb == 1:
                # we have a bug in this cell and one neighbor, lives
                result = result or pb
                # else it will be empty
            elif (n and 1) == 0 and (nb == 1 or nb == 2):
                # empty cell, one or two bugs adjacent, infested
                result = result or pb
            n = n shr 1

proc part1(input: string): int =
    var seen = Table[int,bool]()
    var n = readEris(input)
    seen[n] = true
    while true:
        n = stepEris(n)
        if seen.hasKey(n):
            return n
        seen[n] = true

echo "Biodiversity rating: ", part1("""
.....
...#.
.#..#
.#.#.
...##
""") # 18370591

when defined(test1):
    let n = readEris("""
....#
#..#.
#..##
..#..
#....""")
    echo n
    drawEris(n)
    var m = stepEris(n)
    drawEris(m)
    m = stepEris(m)
    drawEris(m)
    m = stepEris(m)
    drawEris(m)
    m = stepEris(m)
    drawEris(m)
    echo "Biodiversity rating: ", part1("""
....#
#..#.
#..##
..#..
#....""")

