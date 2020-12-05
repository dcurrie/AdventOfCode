import strutils, sequtils, strscans, os, sets, tables, parseutils, intsets

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "input01.txt"
    input = readFile(fname)

#echo("Params: ", params)

proc part2(input: string): int =
    var seats = initIntSet()
    for line in input.splitLines:
        if line != "":
            var x:int
            if parseutils.parseBin(line, x) == 10:
                seats.incl(x)
    var left = false
    for i in 0..0x3ff:
        if seats.contains(i):
            left = true
        else:
            if left:
                if seats.contains(i+1):
                    return i
            left = false
    return 0

echo("Part 2: ", part2(input))
