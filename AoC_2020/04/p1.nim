import strutils, sequtils, strscans, os, sets, tables

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "input.txt"
    input = readFile(fname)

#echo("Params: ", params)

# byr (Birth Year)
# iyr (Issue Year)
# eyr (Expiration Year)
# hgt (Height)
# hcl (Hair Color)
# ecl (Eye Color)
# pid (Passport ID)
# cid (Country ID)

var keys = toHashSet(["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid", "cid"])

proc keymatcher(input: string; match: var string, start: int) : int =
    result = 0
    var s = input.substr(0,2)
    if keys.contains(s):
        match = s
        return 3

var seps: set[char] = {' ', '\n', '\t', '\r'}

proc valmatcher(input: string; match: var string, start: int) : int =
    result = 0
    while start+result < input.len and not (input[start+result] in seps):
        inc result
    match = input.substr(start,start+result-1)

proc part1(input: string): int =
    var valid = 0
    var h:Table[string, string]

    for line in input.splitLines:
        if line != "":
            var k:string
            var v:string
            var x = 0
            while x < line.len() and scanf(line.substr(x), "${keymatcher}:${valmatcher}$s", k, v):
                    h[k] = v
                    x = x + k.len() + v.len() + 2
        else:
            # check
            if h.len() == 8:
                valid.inc()
            if h.len() == 7 and not h.hasKey("cid"):
                valid.inc()
            #echo(h.len(), " ", $h)
            h.clear()
    return valid

echo("Part 1: ", part1(input))
