import strutils, sequtils, strscans, os, sets, tables, parseutils, sugar

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "input.txt"
    input = readFile(fname)

#echo("Params: ", params)

proc part1(input: string): int =
    var lines = input.strip.splitLines
    var earliest = parseInt(lines[0])
    var minwait = 1000000000
    var minid = -1
    for idstr in lines[1].split(','):
        var id: int
        if parseutils.parseInt(idstr, id) > 0:
            var wait = id - (earliest mod id)
            if wait < minwait:
                minwait = wait
                minid = id
    result = minwait * minid

echo("Part 1 ex: ", part1("""939
7,13,x,x,59,x,31,19"""))

echo("Part 1: ", part1(input))
