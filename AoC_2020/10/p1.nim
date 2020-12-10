import strutils, sequtils, strscans, os, sets, tables, algorithm, parseutils

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "input.txt"
    input = readFile(fname)

#echo("Params: ", params)

proc part1(input: string): int =
    var adapters : seq[int] = input.strip.splitLines.map(parseInt)
    sort(adapters, system.cmp[int])
    var diff1 = 0
    var diff3 = 1 # for final diff to device
    var prev = 0
    for i in 0..adapters.len-1:
        var diff = adapters[i] - prev
        if diff == 1:
            diff1 += 1
        elif diff == 3:
            diff3 += 1
        else:
            discard
        prev = adapters[i]
    echo(diff1, " ", diff3)
    result = diff1 * diff3

echo("Part 1: ", part1(input))

echo ("Part 1 ex ", part1("""28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3"""))
