import strutils, sequtils, strscans, os, tables, sets, sugar, unicode

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "input.txt"
    input = readFile(fname).splitLines

type
    Inst = tuple [op: string, oand: int]

proc part1(input: seq[string]): int =
    var acc = 0
    var pc = 0
    var cnt: seq[int] = input.map((a) => 0)
    var pgm: seq[Inst] = collect(newSeq):
        for line in input:
            if line != "":
                var inst = line.split(" ")
                (op : inst[0], oand : parseint(inst[1]))
    for i in 1..1000000000:
        if cnt[pc] != 0:
            return acc
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
            return 0

echo("Part 1, acc: ", part1(input))
