import strutils, sequtils, strscans, os

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "in1.txt"
    input = readFile(fname).splitLines

#echo("Params: ", params)

proc decode(op: var int): (int, int, int, int) =
    let opc = op mod 100
    op = op div 100
    let amode = op mod 10
    op = op div 10
    let bmode = op mod 10
    op = op div 10
    let cmode = op mod 10
    return (opc, amode, bmode, cmode)

proc fetch(pgm: openArray[int], mode: int, parm: int): int = 
    if mode == 0:
        result = pgm[parm]
    elif mode == 1:
        result = parm
    else:
        result = -888888888

proc pgm_input(): int = 1

var zeroes = 0

proc pgm_output(i: int) =
    if i == 0:
        zeroes += 1
    else:
        echo "Out: ", zeroes, " ", i

proc run(pgm: var openArray[int]): int =
    var pc = 0
    var (op, amode, bmode, cmode) = decode(pgm[pc])
    echo (op, amode, bmode, cmode)
    while op != 99:
        if op == 1:
            let a = fetch(pgm, amode, pgm[pc+1])
            let b = fetch(pgm, bmode, pgm[pc+2])
            let c = pgm[pc+3]
            #echo (1, a, b, c)
            pgm[c] = a + b
            pc += 4
        elif op == 2:
            let a = fetch(pgm, amode, pgm[pc+1])
            let b = fetch(pgm, bmode, pgm[pc+2])
            let c = pgm[pc+3]
            pgm[c] = a * b
            pc += 4
        elif op == 3:
            let a = pgm[pc+1]
            pgm[a] = pgm_input()
            #echo (a, pgm[a])
            pc += 2
        elif op == 4:
            let a = fetch(pgm, amode, pgm[pc+1])
            pgm_output(a)
            pc += 2
        else:
            echo "Bad op ", op, " at ", pc
            return -99999999
        (op, amode, bmode, cmode) = decode(pgm[pc])
        echo (op, amode, bmode, cmode)
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
    let res = run(pgm)
    echo("Part 1: ", res, " (", zeroes, ")")

part1()

