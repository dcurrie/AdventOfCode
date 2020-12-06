
import strutils, sequtils, strscans, os, sets, tables, parseutils

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "input.txt"
    input = readFile(fname)

#echo("Params: ", params)

proc part1(input: string): int =
    var groups : seq[int] = @[]
    for answers in input.split("\n\n"):
        var counts:array[26, int]
        for c in answers:
            if c >= 'a' and c <= 'z':
                counts[int(c)-int('a')] = 1
        groups.add(counts.count(1))
    return foldl(groups, a + b, 0)

echo("Part 1: ", part1(input))
