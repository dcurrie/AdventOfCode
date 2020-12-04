import strutils, sequtils, strscans, os

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "input.txt"
    input = readFile(fname)

#echo("Params: ", params)

proc readIn(input: string): seq[seq[int]] =
    #var y = 0
    for line in input.splitLines:
        if line != "":
            var ln: seq[int] = @[]
            for x in 0..(line.len - 1):
                if line[x] == '#':
                    ln.add(-1)
                elif line[x] == '.':
                    ln.add(0)
                else:
                    echo("Yuck: ", line[x])
            result.add(ln)
            #y += 1

func count(forest: var seq[seq[int]], x: int, y: int): int =
    var trees = forest[y][x]
    if y >= (forest.len - 1) or trees > 0:
        return forest[y][x]
    result = count(forest, (x + 3) mod forest[0].len, y + 1) - trees
    forest[y][x] = result

proc part1() =
    var forest = readIn(input)
    echo("Part 1: ", count(forest, 0, 0))

part1()
