import strutils, sequtils, strscans, os

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "in1.txt"
    input = readFile(fname).splitLines

#echo("Params: ", params)

proc decode(opin: int): (int, int, int, int) =
    var op = opin
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

var the_input = @[1,]

proc pgm_input(): int = pop(the_input)

var zeroes = 0

var last_out = 0

proc pgm_output(i: int) =
    if i == 0:
        zeroes += 1
        last_out = i
        echo "Out: (", zeroes, ") ", i
    else:
        last_out = i
        echo "Out: (", zeroes, ") ", i

var trace = false

#proc run(pgm: var openArray[int]): int =
proc run(pgm: var seq[int]): int =
    zeroes = 0
    var pc = 0
    var (op, amode, bmode, cmode) = decode(pgm[pc])
    if trace: echo "@", pc, (op, amode, bmode, cmode), pgm[pc+1], ",", pgm[pc+2], ",", pgm[pc+3]
    while op != 99:
        case op 
        of 1:
            let a = fetch(pgm, amode, pgm[pc+1])
            let b = fetch(pgm, bmode, pgm[pc+2])
            let c = pgm[pc+3]
            if trace: echo 1, (a, b, c)
            pgm[c] = a + b
            pc += 4
        of 2:
            let a = fetch(pgm, amode, pgm[pc+1])
            let b = fetch(pgm, bmode, pgm[pc+2])
            let c = pgm[pc+3]
            if trace: echo 2, (a, b, c)
            pgm[c] = a * b
            pc += 4
        of 3:
            let a = pgm[pc+1]
            pgm[a] = pgm_input()
            if trace: echo 3, (a, pgm[a])
            pc += 2
        of 4:
            let a = fetch(pgm, amode, pgm[pc+1])
            pgm_output(a)
            pc += 2
        of 5:
            let a = fetch(pgm, amode, pgm[pc+1])
            let b = fetch(pgm, bmode, pgm[pc+2])
            #let b = pgm[pc+2]
            if trace: echo 5, (a, b)
            if a != 0:
                pc = b
            else:
                pc += 3
        of 6:
            let a = fetch(pgm, amode, pgm[pc+1])
            let b = fetch(pgm, bmode, pgm[pc+2])
            #let b = pgm[pc+2]
            if a == 0:
                pc = b
            else:
                pc += 3
        of 7:
            let a = fetch(pgm, amode, pgm[pc+1])
            let b = fetch(pgm, bmode, pgm[pc+2])
            let c = pgm[pc+3]
            if a < b:
                pgm[c] = 1
            else:
                pgm[c] = 0
            pc += 4
        of 8:
            let a = fetch(pgm, amode, pgm[pc+1])
            let b = fetch(pgm, bmode, pgm[pc+2])
            let c = pgm[pc+3]
            if a == b:
                pgm[c] = 1
            else:
                pgm[c] = 0
            pc += 4
        else:
            echo "Bad op ", op, " at ", pc
            return -99999999
        (op, amode, bmode, cmode) = decode(pgm[pc])
        if trace: echo "@", pc, (op, amode, bmode, cmode), pgm[pc+1], ",", pgm[pc+2], ",", pgm[pc+3]
    return pgm[0]

proc readin(): seq[int] =
    var pgm: seq[int]
    for line in input:
        if line != "":
            var codes = line.split(',')
            for s in codes:
                pgm.add(parseInt(s))
    return pgm


when defined(test2):
    trace = false
    var pgm = @[3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9]
    the_input = @[1,]
    doAssert(0 != run(pgm))
    doAssert(1 == last_out)
    pgm = @[3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9]
    the_input = @[0,]
    doAssert(0 != run(pgm))
    doAssert(0 == last_out)

    pgm = @[3,3,1105,-1,9,1101,0,0,12,4,12,99,1]
    the_input = @[1,]
    doAssert(0 != run(pgm))
    doAssert(1 == last_out)
    pgm = @[3,3,1105,-1,9,1101,0,0,12,4,12,99,1]
    the_input = @[0,]
    doAssert(0 != run(pgm))
    doAssert(0 == last_out)


    pgm = @[3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,
            4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99]
    the_input = @[7,]
    doAssert(0 != run(pgm))
    doAssert(999 == last_out)
    pgm = @[3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,
            4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99]
    the_input = @[8,]
    doAssert(0 != run(pgm))
    doAssert(1000 == last_out)
    pgm = @[3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,
            4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99]
    the_input = @[9,]
    doAssert(0 != run(pgm))
    doAssert(1001 == last_out)

    pgm = @[3,9,8,9,10,9,4,9,99,-1,8]
    the_input = @[8,]
    doAssert(0 != run(pgm))
    doAssert(1 == last_out)
    pgm = @[3,9,8,9,10,9,4,9,99,-1,8]
    the_input = @[7,]
    doAssert(0 != run(pgm))
    doAssert(0 == last_out)

    pgm = @[3,9,7,9,10,9,4,9,99,-1,8]
    the_input = @[7,]
    doAssert(0 != run(pgm))
    doAssert(1 == last_out)
    pgm = @[3,9,7,9,10,9,4,9,99,-1,8]
    the_input = @[8,]
    doAssert(0 != run(pgm))
    doAssert(0 == last_out)

    pgm = @[3,3,1108,-1,8,3,4,3,99]
    the_input = @[7,]
    doAssert(0 != run(pgm))
    doAssert(0 == last_out)
    pgm = @[3,3,1108,-1,8,3,4,3,99]
    the_input = @[8,]
    doAssert(0 != run(pgm))
    doAssert(1 == last_out)

    pgm = @[3,3,1107,-1,8,3,4,3,99]
    the_input = @[7,]
    doAssert(0 != run(pgm))
    doAssert(1 == last_out)
    pgm = @[3,3,1107,-1,8,3,4,3,99]
    the_input = @[8,]
    doAssert(0 != run(pgm))
    doAssert(0 == last_out)

proc part2() =
    var pgm = readin()
    # echo pgm
    the_input = @[5,]
    trace = false
    let res = run(pgm)
    echo("Part 2: ", res, " (", zeroes, ")")

part2()

