import strutils, sequtils, strscans, os, sets, tables, parseutils

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

# byr (Birth Year) - four digits; at least 1920 and at most 2002.
# iyr (Issue Year) - four digits; at least 2010 and at most 2020.
# eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
# hgt (Height) - a number followed by either cm or in:
# If cm, the number must be at least 150 and at most 193.
# If in, the number must be at least 59 and at most 76.
# hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
# ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
# pid (Passport ID) - a nine-digit number, including leading zeroes.
# cid (Country ID) - ignored, missing or not.

var eyes = toHashSet(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"])

proc part2(input: string): int =
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
            if h.len() == 8 or (h.len() == 7 and not h.hasKey("cid")):
                var good = 1
                # byr (Birth Year) - four digits; at least 1920 and at most 2002.
                var byri: int
                if parseutils.parseInt(h["byr"], byri) != 4 or byri < 1920 or byri > 2002:
                    #echo("byr: ", byri)
                    good = 0
                # iyr (Issue Year) - four digits; at least 2010 and at most 2020.
                var iyri: int
                if parseutils.parseInt(h["iyr"], iyri) != 4 or iyri < 2010 or iyri > 2020:
                    #echo("iyr: ", iyri)
                    good = 0
                # eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
                var eyri: int
                if parseutils.parseInt(h["eyr"], eyri) != 4 or eyri < 2020 or eyri > 2030:
                    #echo("eyr: ", eyri)
                    good = 0
                # hgt (Height) - a number followed by either cm or in:
                # If cm, the number must be at least 150 and at most 193.
                # If in, the number must be at least 59 and at most 76.
                var hgt = h["hgt"]
                var hgti: int
                var hunits = hgt.substr(hgt.len() - 2)
                discard parseutils.parseInt(hgt, hgti)
                if hunits == "in":
                    if hgti < 59 or hgti > 76: good = 0
                elif hunits == "cm":
                    if hgti < 150 or hgti > 193: good = 0
                else:
                    #echo("hgt: ", hgti, " ", hgt, hunits)
                    good = 0
                # hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
                var hcl = h["hcl"]
                var hcli: int
                if hcl[0] != '#' or hcl.len() != 7 or parseutils.parseHex(hcl.substr(1), hcli) != 6:
                    good = 0
                # ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
                if not eyes.contains(h["ecl"]):
                    good = 0
                # pid (Passport ID) - a nine-digit number, including leading zeroes.
                var pid = h["pid"]
                var pidi: int
                if pid.len != 9 or parseutils.parseInt(pid, pidi) != 9:
                    good = 0
                # cid (Country ID) - ignored, missing or not.
                valid = valid + good
            #echo(h.len(), " ", $h)
            h.clear()
    return valid

echo("Part 2: ", part2(input))
