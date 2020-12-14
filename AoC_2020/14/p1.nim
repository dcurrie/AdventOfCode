import strutils, sequtils, strscans, os, sets, tables, parseutils, sugar

let
    params = commandLineParams()
    fname = if params.len > 0 : params[0] else : "input.txt"
    input = readFile(fname)

#echo("Params: ", params)

var memory: Table[uint64, uint64]

proc valmatcher(input: string; match: var uint64, start: int) : int =
    result = 0
    while start+result < input.len and (input[start+result]).isDigit:
        inc result
    discard parseBiggestUInt(input.substr(start,start+result-1), match)

proc part1(input: string): uint64 =
    var lines = input.strip.splitLines
    var maskAnd: uint64
    var maskOr:  uint64
    var address: uint64
    var value:   uint64

    memory.clear

    for line in lines:
        var kv = line.split('=')
        if kv[0] == "mask ":
            var maskstr = kv[1].strip
            if maskstr.replace('X', '1').parseBin(maskAnd) != 36:
                echo("bin? ", kv)
            if maskstr.replace('X', '0').parseBin(maskOr) != 36:
                echo("bin? ", kv)
        elif scanf(line, "mem[${valmatcher}] = ${valmatcher}", address, value):
            memory[address] = (value and maskAnd) or maskOr
        else:
            echo("wtf: ", line, " ", kv[1])
    for x in memory.values:
        # result = (result + x) and uint64(0xFFFFFFFFF)
        result += x


echo("Part 1 ex: ", part1("""mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
mem[8] = 11
mem[7] = 101
mem[8] = 0
"""))

echo("Part 1: ", part1(input))
# wrong because memory was not cleared:
# 12135523361069 = 0x B09 858F 212D
#    40895455533 = 0x   9 858F 212D
# wrong because it's not really a 36 bit memory?:
#    40895455368 = 0x   9 858F 2088
# Correct:
# 12135523360904 = 0x B09 858F 2088
