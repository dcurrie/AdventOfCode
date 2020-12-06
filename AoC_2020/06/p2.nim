
import strutils, sequtils, strscans, os, sets, tables, parseutils

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "input.txt"
    input = readFile(fname)

#echo("Params: ", params)

proc part2(input: string): int =
    var groups : seq[int] = @[]
    for answers in input.split("\n\n"):
        var counts:array[26, int]
        var qlines = count(answers, '\n') + 1
        #echo(lines)
        for line in answers.splitLines():
            var lcounts:array[26, int]
            for c in line:
                if c >= 'a' and c <= 'z':
                    lcounts[int(c)-int('a')] = 1
            for i in 0..25:
                counts[i] += lcounts[i]
        groups.add(counts.count(qlines))
    return foldl(groups, a + b, 0)

echo("Part 2: ", part2(input))
echo("Part 2: ", part2("""abc

a
b
c

ab
ac

a
a
a
a

b"""))
