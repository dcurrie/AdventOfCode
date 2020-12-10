import strutils, sequtils, strscans, os, sets, tables, algorithm, parseutils

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "input.txt"
    input = readFile(fname)

#echo("Params: ", params)

proc part1(input: string): int =
    var adapters : seq[int] = input.strip.splitLines.map(parseInt)
    sort(adapters, system.cmp[int])
    var diffx = 0
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
            diffx += 1
        prev = adapters[i]
    echo(diff1, " ", diff3, " ", diffx)
    result = diff1 * diff3

#echo("Part 1: ", part1(input))

# 71 34 0
# Part 1: 2414
# 22 10 0
# ("Part 1 ex ", 220)

# gap of 3: both required (1 option)
# gap of 1 between non-required adapters: either, both, or neither (4 options)
# gap of 1 between required and non-required adapters: depends on following?

# brute force, with memoization

var memo : Table[(int, int), int]

proc permu(adapters: seq[int], prev: int, n: int): int =
    # adapters[n] is candidate for removal
    # prev is adapters[n-1]
    if n >= adapters.len-1:
        return 1
    if memo.hasKey((prev,n)):
        return memo[(prev,n)]
    # case where adapter remains
    var perms = permu(adapters, adapters[n], n+1)
    if adapters[n] - prev == 3 or adapters[n+1] - adapters[n] == 3:
        # adapter cannot be removed
        discard
    else:
        perms += permu(adapters, prev, n+1)
    memo[(prev,n)] = perms
    return perms

proc part2(input: string): int =
    var adapters : seq[int] = input.strip.splitLines.map(parseInt)
    sort(adapters, system.cmp[int])
    memo.clear()
    result = permu(adapters, 0, 0)


echo ("Part 2 ex ", part2("""28
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

echo ("Part 2 ", part2(input))
