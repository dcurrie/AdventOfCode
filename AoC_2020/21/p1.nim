import strutils, sequtils, strscans, os, sets, tables, parseutils, sugar, algorithm

let
    params = commandLineParams()
    fname = if params.len > 0 : params[0] else : "input.txt"
    input = readFile(fname)

#echo("Params: ", params)

var allergens: Table[string, HashSet[string]]

#type ingredient = tuple[occurs: int, allergen: bool]
var ing_occurances: CountTable[string]
var ing_allergen: Table[string, string] # ingredient -> allergen

proc readIn(input: string) =
    for line in input.strip.splitLines:
        var lr = line.split(" (contains ")
        var w: string
        var s: string
        var hs: HashSet[string]
        var r = lr[0]
        while r.scanf("$s$w$*", w, s):
            hs.incl(w)
            if ing_occurances.contains(w):
                ing_occurances.inc(w)
            else:
                ing_occurances[w] = 1
            r = s
        r = lr[1].strip(chars={')'})
        #echo(r)
        while r.scanf("$s$w$*", w, s):
            #echo(w)
            if allergens.contains(w):
                allergens[w] = intersection(allergens[w], hs)
            else:
                allergens[w] = hs
            r = s.strip(chars={','})

proc find1(): (string, string) = # allergen, ingredient
    for k, v in pairs(allergens):
            if v.card == 1:
                return (k,v.toSeq[0])
    return ("","")

proc part1(input: string): int =
    readIn(input)
    var remaining: HashSet[string]
    for k in keys(allergens):
        remaining.incl(k)
    while remaining.card > 0:
        var (k, v) = find1()
        if k == "":
            echo("ugh ", remaining, allergens)
            return 0
        remaining.excl(k)
        for a, i in mpairs(allergens):
            i.excl(v)
        ing_allergen[v] = k
    for k, v in ing_occurances:
        if ing_allergen.contains(k):
            discard
        else:
            result += v

echo("Part 1: ", part1(input))

# this fails unless the above line is commented out because there is uninitialized state
echo("Part 1 ex: ", part1("""mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
trh fvjkl sbzzf mxmxvkd (contains dairy)
sqjhc fvjkl (contains soy)
sqjhc mxmxvkd sbzzf (contains fish)"""))

