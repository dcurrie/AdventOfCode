
import strutils, sequtils, strscans, os

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "input.txt"
    input = readFile(fname) # .splitLines

#echo("Params: ", params)

proc readIn(input: string): seq[int] =
    var v = 0
    for line in input.splitLines:
        if line != "":
            if scanf(line, "$i", v):
                result.add(v)

proc part1(): int =
    var vs = readIn(input)
    for v in vs:
        for w in vs:
            if v + w == 2020:
                return v * w

# echo("Part 1: ", part1())

proc part2(): int =
    var vs = readIn(input)
    for v in vs:
        for w in vs:
            if v + w <= 2020:
                for x in vs:
                    if v + w + x == 2020:
                        return v * w * x

echo("Part 2: ", part2())
