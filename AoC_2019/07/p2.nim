import strutils, sequtils, strscans, os, tables, algorithm

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

var trace = false

var machine = 0
var pcsave  = [0,0,0,0,0]
var toggles = [false,false,false,false,false]
var outputs = [0,0,0,0,0]
var halted  = [false,false,false,false,false]

var inputs  = [4,3,2,1,0]

proc resetvm() =
    machine = 0
    pcsave  = [0,0,0,0,0]
    toggles = [false,false,false,false,false]
    outputs = [0,0,0,0,0]
    halted  = [false,false,false,false,false]

proc pgm_input(): int = 
    if toggles[machine]:
        result = outputs[machine]
    else:
        result = inputs[machine]
        toggles[machine] = true

proc pgm_output(i: int) =
    outputs[(machine+1) mod 5] = i

proc run(pgm: var seq[int]) = 
    var pc = pcsave[machine]
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
            pcsave[machine] = pc
            return
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
            halted[machine] = true
            return
        (op, amode, bmode, cmode) = decode(pgm[pc])
        if trace: echo "@", pc, (op, amode, bmode, cmode), pgm[pc+1], ",", pgm[pc+2], ",", pgm[pc+3]
    halted[machine] = true

proc readin(): seq[int] =
    var pgm: seq[int]
    for line in input:
        if line != "":
            var codes = line.split(',')
            for s in codes:
                pgm.add(parseInt(s))
    return pgm

var pgms: array[0..4,seq[int]]

proc run5() =
    for i in 0..4:
        machine = i
        if not halted[i]: run(pgms[i])

proc runmax(pgm: var seq[int]): int =
    result = 0
    inputs = [5,6,7,8,9]
    while nextPermutation(inputs): ## note that we're doing to try our luck skiping the first permutation
        for i in 0..4: pgms[i] = deepCopy(pgm)
        resetvm()
        while any(halted, proc (x: bool): bool = return not x):
            run5()
        if outputs[0] > result:
            result = outputs[0]
            echo inputs, outputs, "*********"
        else:
            echo inputs, outputs

when defined(test2):
    var pgm = @[3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]
    echo "Max :", runmax(pgm)

proc part2() =
    var pgm = readin()
    echo("Part 2: ", runmax(pgm))

part2()

