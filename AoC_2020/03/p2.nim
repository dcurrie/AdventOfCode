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
    if y >= forest.len:
        return 0 # needed if run past end
    result = count(forest, (x + 3) mod forest[0].len, y + 1) - trees
    forest[y][x] = result

proc part1() =
    var forest = readIn(input)
    echo("Part 1: ", count(forest, 0, 0))

#part1()

# Right 1, down 1.
# Right 3, down 1.
# Right 5, down 1.
# Right 7, down 1.
# Right 1, down 2.

proc part2a() =
    var r = 1
    var d = 1
    var forest = readIn(input)
    func countt(f: var seq[seq[int]], x: int, y: int): int =
        if y >= f.len:
            return 0 # needed if run past end
        var trees = f[y][x]
        if trees > 0:
            return trees
        #if y >= (f.len - 1):
        #    return abs(trees)
        result = count(f, (x + r) mod f[0].len, y + d) - trees
        f[y][x] = result

    var r1d1 = countt(forest, 0, 0)
    r = 3
    d = 1
    forest = readIn(input)
    var r3d1 = countt(forest, 0, 0)
    r = 5
    d = 1
    forest = readIn(input)
    var r5d1 = countt(forest, 0, 0)
    r = 7
    d = 1
    forest = readIn(input)
    var r7d1 = countt(forest, 0, 0)
    r = 1
    d = 2
    forest = readIn(input)
    var r1d2 = countt(forest, 0, 0)
    #
    echo("Part 2: ", r1d1, " * ", r3d1, " * ", r5d1, " * ", r7d1, " * ", r1d2, " = ")
    echo("Part 2: ", r1d1 * r3d1 * r5d1 * r7d1 * r1d2)

proc part2() =
    var r = 1
    var d = 1
    var forest = readIn(input)
    func countt(f: var seq[seq[int]]): int =
        var x = 0
        var y = 0
        result = 0
        while y < f.len:
            result += f[y][x]
            x = (x + r) mod f[0].len
            y = y + d

    var r1d1 = -countt(forest)
    r = 3
    d = 1
    var r3d1 = -countt(forest)
    r = 5
    d = 1
    var r5d1 = -countt(forest)
    r = 7
    d = 1
    var r7d1 = -countt(forest)
    r = 1
    d = 2
    var r1d2 = -countt(forest)
    #
    echo("Part 2: ", r1d1, " * ", r3d1, " * ", r5d1, " * ", r7d1, " * ", r1d2, " = ")
    echo("Part 2: ", r1d1 * r3d1 * r5d1 * r7d1 * r1d2)

part2()

# recursive, wrong (but right on part 1!)
# Part 2: 79 * 205 * 73 * 65 * 82 =
# Part 2: 6301312550
# iterative, correct
# Part 2: 87 * 205 * 85 * 79 * 33 =
# Part 2: 3952146825
