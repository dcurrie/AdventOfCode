import strutils, sequtils, strscans, os, tables, algorithm

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

var trace = false

var machine = 0
var toggle  = false
var inputs  = [4,3,2,1,0]
var outputs = [0,0,0,0,0,0]

proc pgm_input(): int = 
    if toggle:
        result = outputs[machine]
    else:
        result = inputs[machine]
    toggle = not toggle

proc pgm_output(i: int) =
    outputs[machine+1] = i

proc run(pgm: var seq[int]): int =
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
            return 0                                ############### quick out
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

var cache: Table[int,int]

proc runcached(pgm: var seq[int]): int =
    let key = inputs[machine] + outputs[machine] * 5
    if cache.hasKey(key):
        return cache[key]
    else:
        discard run(pgm)
        cache[key] = outputs[machine+1]
        return outputs[machine+1]

proc readin(): seq[int] =
    var pgm: seq[int]
    for line in input:
        if line != "":
            var codes = line.split(',')
            for s in codes:
                pgm.add(parseInt(s))
    return pgm

proc run5(pgm: var seq[int]): int =
    for i in 0..4:
        machine = i
        var copy = deepCopy(pgm)
        #result = runcached(copy)
        result = run(copy)

#proc incrin(): bool =
#    for i in 0..4:
#        inputs[i] += 1
#        if inputs[i] < 9:
#            return true
#        else:
#            inputs[i] = 0
#    return false

#proc nextPermutation[T](x: var openArray[T]): bool {...}

proc runmax(pgm: var seq[int]): int =
    result = 0
    inputs = [0,1,2,3,4]
    cache.clear()
    #for i in 0..4: inputs[i] = 0
    while nextPermutation(inputs):
        discard run5(pgm)
        if outputs[5] > result:
            result = outputs[5]
            echo inputs, outputs, "*********"
        echo inputs, outputs

when defined(test1):
    var pgm = @[3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]
    discard run5(pgm)
    echo outputs
    echo "Max :", runmax(pgm)

proc part1() =
    var pgm = readin()
    echo("Part 1: ", runmax(pgm))

part1()

