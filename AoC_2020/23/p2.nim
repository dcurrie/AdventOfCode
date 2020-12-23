import strutils, sequtils, strscans, os, sets, tables, parseutils, sugar, algorithm, deques

#let
#    params = commandLineParams()
#    fname = if params.len > 0 : params[0] else : "input.txt"
#    input = readFile(fname)

#echo("Params: ", params)

# Each move, the crab does the following actions:
#
# The crab picks up the three cups that are immediately clockwise of the current cup. They are removed from the circle;
#   cup spacing is adjusted as necessary to maintain the circle.
# The crab selects a destination cup: the cup with a label equal to the current cup's label minus one.
#    If this would select one of the cups that was just picked up, the crab will keep subtracting one
#    until it finds a cup that wasn't just picked up. If at any point in this process the value goes
#    below the lowest value on any cup's label, it wraps around to the highest value on any cup's label instead.
# The crab places the cups it just picked up so that they are immediately clockwise of the destination cup. They keep the same order as when they were picked up.
# The crab selects a new current cup: the cup which is immediately clockwise of the current cup.

proc show(cups: seq[int32], cc: int) =
    #if cups.len > 10:
    #    return
    var i = cc
    var s = $cc
    for _ in 1..9:
        s &= "," & $cups[i mod cups.len]
        i = cups[i mod cups.len]
    echo s

proc part2(input: string, size: int, moves: int): int =
    var cups = newSeq[int32](size) # cups indexed by cup value, holds "cup after"
    var last = (ord(input[0]) - ord('0')) mod size
    var cup1 = last
    for c in input[1..^1]:
        var n = (ord(c) - ord('0')) mod size
        cups[last] = int32(n) # mod size needed for part 1
        last = n
    if size > input.len:
        for i in input.len+1..size-1:
            cups[last] = int32(i)
            last = i
        cups[0] = int32(cup1) # make the circle
    else:
        cups[last mod size] = int32(cup1)
    #show(cups, cup1)
    #echo("cup1: ", cup1, " cups[0]: ", cups[0], " cups[size-1]: ", cups[size-1])
    # note that cups[0] is really cups[size] since crabs use 1-based arrays, Nim 0-based
    var cc = cup1 # start of circular list
    for _ in 1..moves:
        var tc = int32((cc + size - 1) mod size)
        var t1 = cups[cc]
        var t2 = cups[t1]
        var t3 = cups[t2]
        while tc == t1 or tc == t2 or tc == t3:
            tc = int32((tc + size - 1) mod size)
        #if moves < 11: echo((cc, tc))
        var nc = cups[t3]
        cups[t3] = cups[tc]
        cups[tc] = t1
        cups[cc] = nc
        cc = nc # step right
        #if moves < 11: show(cups, size)
    # Part 1
    # After the crab is done, what order will the cups be in? Starting after the cup labeled 1,
    # collect the other cups' labels clockwise into a single string with no extra characters;
    # each number except 1 should appear exactly once.
    show(cups, 1)
    # Part 2
    result = int(cups[1]) * int(cups[cups[1]])

proc part1(input: string, moves: int): int =
    return part2(input, input.len, moves)

echo "Part 1 ex: ", part1("389125467", 10)
echo "Part 1:    ", part1("198753462", 100)

echo "Part 2 ex: ", part2("389125467", 1000000, 10000000)
echo "Part 2:    ", part2("198753462", 1000000, 10000000)
