
import strutils, sequtils, strscans, os, bitops

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

proc countAdjacent(e: array[-201..201,int], lvl, p: int): int =
    let i = e[lvl+1]
    let n = e[lvl]
    let o = e[lvl-1]
    template gb(v, z: int): int = (v shr (z - 1)) and 1
    case p:
    of  1: gb(o, 8) + gb(o,12) + gb(n, 2) + gb(n, 6)
    of  2: gb(o, 8) + gb(n, 1) + gb(n, 3) + gb(n, 7)
    of  3: gb(o, 8) + gb(n, 2) + gb(n, 4) + gb(n, 8)
    of  4: gb(o, 8) + gb(n, 3) + gb(n, 5) + gb(n, 9)
    of  5: gb(o, 8) + gb(n, 4) + gb(o,14) + gb(n,10)
    of  6: gb(n, 1) + gb(o,12) + gb(n, 7) + gb(n,11)
    of  7: gb(n, 2) + gb(n, 6) + gb(n, 8) + gb(n,12)
    of  8: gb(n, 3) + gb(n, 7) + gb(n, 9)            + gb(i, 1) + gb(i, 2) + gb(i, 3) + gb(i, 4) + gb(i, 5)
    of  9: gb(n, 4) + gb(n, 8) + gb(n,10) + gb(n,14)
    of 10: gb(n, 5) + gb(n, 9) + gb(o,14) + gb(n,15)
    of 11: gb(n, 6) + gb(o,12) + gb(n,12) + gb(n,16)
    of 12: gb(n, 7) + gb(n,11)            + gb(n,17) + gb(i, 1) + gb(i, 6) + gb(i,11) + gb(i,16) + gb(i,21)
    of 13: 0
    of 14: gb(n, 9)            + gb(n,15) + gb(n,19) + gb(i, 5) + gb(i,10) + gb(i,15) + gb(i,20) + gb(i,25)
    of 15: gb(n,10) + gb(n,14) + gb(o,14) + gb(n,20)
    of 16: gb(n,11) + gb(o,12) + gb(n,17) + gb(n,21)
    of 17: gb(n,12) + gb(n,16) + gb(n,18) + gb(n,22)
    of 18:            gb(n,17) + gb(n,19) + gb(n,23) + gb(i,21) + gb(i,22) + gb(i,23) + gb(i,24) + gb(i,25)
    of 19: gb(n,14) + gb(n,18) + gb(n,20) + gb(n,24)
    of 20: gb(n,15) + gb(n,19) + gb(o,14) + gb(n,25)
    of 21: gb(n,16) + gb(o,12) + gb(n,22) + gb(o,18)
    of 22: gb(n,17) + gb(n,21) + gb(n,23) + gb(o,18)
    of 23: gb(n,18) + gb(n,22) + gb(n,24) + gb(o,18)
    of 24: gb(n,19) + gb(n,23) + gb(n,25) + gb(o,18)
    of 25: gb(n,20) + gb(n,24) + gb(o,14) + gb(o,18)
    else: 0

proc stepEris(e: array[-201..201,int], lvl: int): int =
    var n = e[lvl]
    const pb = 1 shl 24 # the bug pos in result
    for p in 1..25:
        result = result shr 1
        let nb = countAdjacent(e, lvl, p)
        if (n and 1) == 1 and nb == 1:
            # we have a bug in this cell and one neighbor, lives
            result = result or pb
            # else it will be empty
        elif (n and 1) == 0 and (nb == 1 or nb == 2):
            # empty cell, one or two bugs adjacent, infested
            result = result or pb
        n = n shr 1

var verbo = false

proc part2(input: string, cnt: int): int =
    let n = readEris(input)
    var e1: array[-201..201,int]
    var e2: array[-201..201,int]
    e1[0] = n
    for i in 1..(cnt div 2):
        for j in -i..i:
            e2[j] = stepEris(e1, j)
        for j in -i..i:
            e1[j] = stepEris(e2, j)
    let i = cnt div 2
    for j in -i..i:
        result = result + countSetBits(e1[j])
    if verbo:
        for j in -i..i:
            echo "Depth ", i
            drawEris(e1[j])

when defined(test2):
    verbo = true
    echo "Bugs present: ", part2("""
....#
#..#.
#..##
..#..
#....""", 10) # 99


echo "Bugs present: ", part2("""
.....
...#.
.#..#
.#.#.
...##
""", 200) # 2040
