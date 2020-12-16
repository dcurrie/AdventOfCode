import strutils, sequtils, strscans, os, sets, tables, algorithm, parseutils, sugar

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

proc badv(v: int): bool =
    for c in constraints.values:
        if (v >= c.fm1 and v <= c.to1) or (v >= c.fm2 and v <= c.to2):
            return false
    return true

proc badt(t: seq[int]): bool =
    for v in t:
        if badv(v):
            return true
    return false

proc check(keys: seq[string], tickets: seq[seq[int]]): bool =
    for i, k in keys:
        var c = constraints[k]
        for t in tickets:
            var v = t[i]
            if (v >= c.fm1 and v <= c.to1) or (v >= c.fm2 and v <= c.to2):
                # good
                discard
            else:
                return false
    return true

# this works for the example, but is too slow for the input; see p2.nim

proc part2(input: string): int =
    readIn(input)
    var tickets: seq[seq[int]]
    for t in otickets:
        if badt(t):
            discard
        else:
            tickets.add(t)
    var keys: seq[string] # = sort(toSeq(constraints.keys))
    for k in constraints.keys:
        keys.add(k)
    sort(keys)
    var next = true
    while next:
        if check(keys, tickets):
            break
        next = nextPermutation(keys)
    var soln = 1
    if next:
        # found
        echo("found ", keys)
        for i, k in keys:
            if k.startsWith("departure"):
                soln *= myticket[i]
    else:
        echo("No permutation works!")
    return soln

echo("Part 2 ex: ", part2("""class: 0-1 or 4-19
row: 0-5 or 8-19
seat: 0-13 or 16-19

your ticket:
11,12,13

nearby tickets:
3,9,18
15,1,5
5,14,9"""))

echo("Part 2: ", part2(input))
