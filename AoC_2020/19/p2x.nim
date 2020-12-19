import strutils, sequtils, strscans, os, sets, tables, parseutils, sugar

let
    params = commandLineParams()
    fname = if params.len > 0 : params[0] else : "input.txt"
    input = readFile(fname)

#echo("Params: ", params)

type Rule = seq[seq[int]]

var rules: Table[int,Rule]
var terms: Table[int,char]
var msgs: seq[string]

proc readIn(input: string) =
    rules.clear
    terms.clear
    var rm = input.strip.split("\n\n")
    msgs = rm[1].splitLines
    for line in rm[0].splitLines:
        var num: int
        var rest: string
        if line.scanf("$i: $*", num, rest):
            var term: string
            if rest.scanf("\"$w\"", term):
                terms[num] = term[0]
            else:
                var rul: Rule
                var alt: seq[int]
                var rnm: int
                var i = 0
                while i < rest.len:
                    var n = rest.parseInt(rnm, i)
                    if n > 0:
                        i += n+1
                        alt.add(rnm)
                    else:
                        if alt.len > 0:
                            rul.add(alt)
                            alt = @[]
                        if rest[i..i+1] == "| ":
                            i += 2
                        else:
                            echo("Ugh: ", i, " ", rest[i], " ", rest)
                            return
                if alt.len > 0:
                    rul.add(alt)
                rules[num] = rul
        else:
            echo("wtf: ", line)

proc parse(msg: string, pos = 0, rnm = 0): seq[int] =
    if pos >= msg.len:
        return
    if rules.contains(rnm):
        for alt in rules[rnm]:
            var z = @[pos]
            for n in alt:
                var w: seq[int]
                for y in z:
                    if y < msg.len:
                        w.add(parse(msg, y, rnm=n))
                z = w
            result.add(z) # if z[0] != pos:
    elif terms.contains(rnm):
        if msg[pos] == terms[rnm]:
            return @[pos+1]

# 8: 42 | 42 8
# 11: 42 31 | 42 11 31

proc part2(input: string): int =
    readIn(input)
    rules[8] = @[@[42],@[42,8]]
    rules[11] = @[@[42,31],@[42,11,31]]
    for msg in msgs:
        if parse(msg).contains(msg.len):
            result += 1

echo("Part 2: ", part2(input))
