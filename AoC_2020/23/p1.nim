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

proc minus1(c: char): char =
    result = char(((ord(c) - 14) mod 9) + ord('1'))

#for i in '1'..'9':
#    echo minus1(i)

proc part1(input: string, moves: int): string =
    var cups = input
    for _ in 1..moves:
        var cc = cups[0]
        var nc = minus1(cc)
        var tc = cups[1..3]
        while nc in tc:
            nc = minus1(nc)
        var i = cups.find(nc,4)
        cups = cups[4..i] & tc & cups[i+1..^1] & cups[0..0]
        #if moves < 11: echo cups
    #var rot = moves mod input.len
    #echo( cups[^rot..^1] & cups[0..^rot+1] )
    # After the crab is done, what order will the cups be in? Starting after the cup labeled 1,
    # collect the other cups' labels clockwise into a single string with no extra characters;
    # each number except 1 should appear exactly once.
    var i = cups.find('1',0)
    if i == cups.len - 1:
        result = cups[0..^2]
    elif i == 0:
        result = cups[1..^1]
    else:
        result = cups[i+1..^1] & cups[0..i-1]


echo part1("389125467", 10)
echo part1("198753462", 100)

