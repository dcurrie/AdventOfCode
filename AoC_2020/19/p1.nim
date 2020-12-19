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

proc parse(msg: string, rnm = 0): int =
    if rules.contains(rnm):
        #echo("Rule ", rnm, rules[rnm])
        for alt in rules[rnm]:
            #echo("Alt ", alt)
            var z = 0
            for n in alt:
                #echo("Alt n ", n)
                z += parse(msg[z..^1], rnm=n)
                #echo(("z", z))
            result = max(result, z)
    elif terms.contains(rnm):
        #echo("Term ", rnm)
        if msg[0] == terms[rnm]:
            return 1

proc part1(input: string): int =
    readIn(input)
    #echo((rules.len, terms.len, msgs.len))
    for msg in msgs:
        if parse(msg) == msg.len:
            result += 1


echo("Part 1 ex2: ", part1("""0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: "a"
5: "b"

aaaabb
aaabab
abbabb
abbbab
aabaab
aabbbb
abaaab
ababbb
y88
aaaaaa
ababab
"""))

echo("Part 1 ex1: ", part1("""0: 1 2
1: "a"
2: 1 3 | 3 1
3: "b"

aab
aba
aaa"""))

echo("Part 1: ", part1(input))
