import strutils, sequtils, strscans, os, sets, tables, parseutils, sugar

proc last(s: openArray[int], start: int, val: int): int =
    result = start
    while result >= 0:
        if s[result] == val:
            return
        result -= 1

proc part1(input: string): int =
    var starting = input.strip.split(',').map(parseInt)
    var numb = newCountTable(starting)
    for i in starting.len..2020:
        var next: int
        var prev = starting[i-1]
        if numb[prev] > 1:
            next = i - last(starting, i - 2, prev) - 1
        else:
            next = 0
        numb.inc(next)
        starting.add(next)
        if i == 10:
            echo(starting)
    result = starting[^2]

echo("Part 1 ex: ", part1("0,3,6"))
echo("Part 1 ex: ", part1("1,3,2"))
echo("Part 1 ex: ", part1("2,1,3"))
echo("Part 1: ", part1("0,13,1,8,6,15"))
