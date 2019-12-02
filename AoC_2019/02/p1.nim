import strutils, sequtils, strscans, os

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "in1.txt"
    input = readFile(fname).splitLines

#echo("Params: ", params)

proc run(pgm: var openArray[int]): int =
    var pc = 0
    var op = pgm[pc]
    while op != 99:
        if op == 1:
            let a = pgm[pc+1]
            let b = pgm[pc+2]
            let c = pgm[pc+3]
            pgm[c] = pgm[a] + pgm[b]
        if op == 2:
            let a = pgm[pc+1]
            let b = pgm[pc+2]
            let c = pgm[pc+3]
            pgm[c] = pgm[a] * pgm[b]
        pc += 4
        op = pgm[pc]
    return pgm[0]

proc readin(): seq[int] =
    var pgm: seq[int]
    for line in input:
        if line != "":
            var codes = line.split(',')
            for s in codes:
                pgm.add(parseInt(s))
    return pgm

proc part1() =
    var pgm = readin()
    # echo pgm
    # replace position 1 with the value 12 and replace position 2 with the value 2.
    pgm[1] = 12
    pgm[2] = 2
    let res = run(pgm)
    echo("Part 1: ", res)

part1()

proc part2guts(): int =
    var orig = readin()
    echo("Len ", orig.len)
    var noun = 0
    while noun < 100:
        var verb = 0
        while verb < 100:
            var pgm = orig
            pgm[1] = noun
            pgm[2] = verb
            let res = run(pgm)
            if res == 19690720:
                return 100 * noun + verb
            verb += 1
        noun += 1
    return -1


proc part2() =
    let res = part2guts()
    echo("Part 2: ", res)

part2()
