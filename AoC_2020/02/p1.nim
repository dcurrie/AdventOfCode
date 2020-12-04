
import strutils, sequtils, strscans, os

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "input.txt"
    input = readFile(fname) # .splitLines

#echo("Params: ", params)

# 1-3 a: abcde

func countchar (c: string, pw: string) : int =
    return count(pw, c[0])

proc part1(input: string): int =
    var cmin = 0
    var cmax = 0
    var c = " "
    var pw = ""
    var good = 0
    var bad = 0
    for line in input.splitLines:
        if line != "":
            if scanf(line, "$i-$i $w: $w", cmin, cmax, c, pw):
                var cnt = countchar(c, pw)
                if cnt < cmin or cnt > cmax:
                    bad = bad + 1
                else:
                    good = good + 1
        else:
            echo "Bad: " .. line
    return good

echo("Part 1: ", part1(input))

# proc part2(): int =
#     var vs = readIn(input)
#     for v in vs:
#         for w in vs:
#             if v + w <= 2020:
#                 for x in vs:
#                     if v + w + x == 2020:
#                         return v * w * x

# echo("Part 2: ", part2())
