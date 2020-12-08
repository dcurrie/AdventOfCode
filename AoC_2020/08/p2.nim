import strutils, sequtils, strscans, os, tables, sets, sugar, unicode

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "input.txt"
    input = readFile(fname).splitLines

type
    Inst = tuple [op: string, oand: int]

proc trial(pgm: seq[Inst]): (bool, int) =
    var acc = 0
    var pc = 0
    var cnt: seq[int] = input.map((a) => 0)
    for i in 1..1000000000:
        if pc == pgm.len:
            return (true, acc)
        if pc > pgm.len or pc < 0:
            return (false, acc)
        if cnt[pc] != 0:
            return (false, acc)
        cnt[pc] = 1
        var (inst, oand) = pgm[pc]
        if inst == "nop":
            pc += 1
        elif inst == "jmp":
            pc += oand
        elif inst == "acc":
            acc += oand
            pc += 1
        else:
            echo("Wtf: ", inst, " ", oand)
            return (false, 0)

proc part2(input: seq[string]): int =
    var pgm: seq[Inst] = collect(newSeq):
        for line in input:
            if line != "":
                var inst = line.split(" ")
                (op : inst[0], oand : parseint(inst[1]))
    for pc in 0..pgm.len-1:
        var (inst, oand) = pgm[pc]
        if inst == "jmp":
            pgm[pc].op = "nop"
        elif inst == "nop":
            pgm[pc].op = "jmp"
        else:
            continue
        var (win, acc) = trial(pgm)
        if win:
            return acc
        pgm[pc].op = inst

echo("Part 2, acc: ", part2(input))

