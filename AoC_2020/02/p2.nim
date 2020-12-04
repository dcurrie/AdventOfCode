
import strutils, sequtils, strscans, os

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "input.txt"
    input = readFile(fname) # .splitLines

#echo("Params: ", params)

# 1-3 a: abcde

# func countchar (c: string, pw: string) : int =
#     return count(pw, c[0])

proc part2(input: string): int =
    var cmin = 0
    var cmax = 0
    var c = " "
    var pw = ""
    var good = 0
    var bad = 0
    for line in input.splitLines:
        if line != "" and scanf(line, "$i-$i $w: $w", cmin, cmax, c, pw):
            if (pw[cmin-1] == c[0]) xor (pw[cmax-1] == c[0]):
                good = good + 1
                #echo("Good: ", c[0], " ", pw[cmin-1], " ", pw[cmax-1], " ", pw)
            else:
                bad = bad + 1
                #echo("Bad:  ", c[0], " ", pw[cmin-1], " ", pw[cmax-1], " ", pw)
    #echo("Bad: ", bad)
    return good

echo("Part 2: ", part2(input))
