import strutils, sequtils, strscans, os, sets, tables, parseutils, sugar

let
    params = commandLineParams()
    fname = if params.len > 0 : params[0] else : "input.txt"
    input = readFile(fname)

type Constraint = tuple[fm1:int, to1:int, fm2:int, to2:int]
var constraints: Table[string,Constraint]
var myticket: seq[int]
var otickets: seq[seq[int]]

proc readIn(input: string) =
    var lines = input.strip.splitLines
    constraints.clear
    otickets = @[]
    var i = 0
    while i < lines.len:
        if lines[i] != "":
            var kv = lines[i].split(':')
            if kv[0] == "your ticket":
                i += 1
                break
            var fm1, to1, fm2, to2: int
            if scanf(kv[1], " $i-$i or $i-$i", fm1, to1, fm2, to2):
                constraints[kv[0]] = (fm1, to1, fm2, to2)
            else:
                echo("wtf: ", lines[i], " = ", kv[0], " > ", kv[1])
        i += 1
    myticket = lines[i].strip.split(',').map(parseInt)
    i += 1
    while i < lines.len:
        if lines[i] != "" and lines[i] != "nearby tickets:":
            otickets.add(lines[i].strip.split(',').map(parseInt))
        i += 1

proc bad(v: int): bool =
    for c in constraints.values:
        if (v >= c.fm1 and v <= c.to1) or (v >= c.fm2 and v <= c.to2):
            return false
    return true

proc part1(input: string): int =
    readIn(input)
    var ser = 0
    for t in otickets:
        for v in t:
            if bad(v):
                ser += v
    return ser

echo("Part 1 ex: ", part1("""class: 1-3 or 5-7
row: 6-11 or 33-44
seat: 13-40 or 45-50

your ticket:
7,1,14

nearby tickets:
7,3,47
40,4,50
55,2,20
38,6,12"""))

echo("Part 1: ", part1(input))
