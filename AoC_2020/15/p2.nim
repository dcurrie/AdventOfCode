import strutils, sequtils, strscans, os, sets, tables, parseutils, sugar

var last: Table[int, (int, int)]

proc addp(n: int, i: int) =
    if last.contains(n):
        var (m1, m2) = last[n]
        last[n] = (i, m1)
    else:
        last[n] = (i, -1)

proc getp(n: int): int =
    var (m1, m2) = last[n]
    return m2

proc part2(input: string): int =
    var starting = input.strip.split(',').map(parseInt)
    last.clear
    for i, n in starting:
        addp(n, i)
    for i in starting.len..30000000: #30000000
        var next: int
        var prev = starting[i-1]
        var pi = getp(prev)
        if pi >= 0:
            next = i - pi - 1
        else:
            next = 0
        addp(next, i)
        starting.add(next)
        if i == 10:
            echo(starting)
            echo(last)
    result = starting[^2]

#echo("Part 2 ex: ", part2("0,3,6"))
#echo("Part 2 ex: ", part2("1,3,2"))
#echo("Part 2 ex: ", part2("2,1,3"))
echo("Part 2: ", part2("0,13,1,8,6,15"))
