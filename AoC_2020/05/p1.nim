import strutils, sequtils, strscans, os, sets, tables, parseutils

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "input01.txt"
    input = readFile(fname)

#echo("Params: ", params)

proc part1(input: string): int =
    var maxseat = 0
    for line in input.splitLines:
        if line != "":
            var x:int
            if parseutils.parseBin(line, x) == 10:
                maxseat = max(maxseat, x)
    return maxseat

echo("Part 1: ", part1(input))
