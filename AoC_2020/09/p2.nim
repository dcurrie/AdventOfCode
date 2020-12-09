import strutils, sequtils, strscans, os, sets, tables, parseutils

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "input.txt"
    input = readFile(fname)

#echo("Params: ", params)

proc part2(input: string): int =
    var codes : seq[int]
    for line in input.splitLines:
        if line != "":
            codes.add(parseint(line))
    var counts : CountTable[int]
    var invalid: int
    for i in 1..codes.len-1:
        if i < 25:
            var new = codes[i]
            for j in 0..i-1:
                counts.inc(new + codes[j])
        elif counts.contains(codes[i]):
            var new = codes[i]
            var old = codes[i-25]
            for j in (i-24)..(i-1):
                counts.inc(old + codes[j], -1)
                counts.inc(new + codes[j])
        else:
            invalid = codes[i]
            break # this is the break I neglected to add the first try
    # part 2
    for i in 0..codes.len-2:
        for j in (i+1)..codes.len-1:
            var ss = foldl(codes[i..j], a + b)
            if ss == invalid:
                # winner!
                echo(ss, " ", codes[i..j])
                return min(codes[i..j]) + max(codes[i..j])
            elif ss > invalid:
                break
            else:
                discard

echo("Part 2: ", part2(input))
