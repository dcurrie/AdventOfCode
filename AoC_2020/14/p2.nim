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

proc muck2 (address, value, maskWc: uint64) =
    var msk = maskWc and (maskWc - 1) # removes LSB
    memory[address or maskWc] = value
    memory[address or msk] = value
    #echo(address, " ", value, " ", maskWc, " ", msk)
    if maskWc != 0:
        muck2(address or (maskWc xor msk), value, msk)
        muck2(address, value, msk)

proc part2(input: string): uint64 =
    var lines = input.strip.splitLines
    var maskWc:  uint64
    var maskOr:  uint64
    var address: uint64
    var value:   uint64

    memory.clear

    # If the bitmask bit is 0, the corresponding memory address bit is unchanged.
    # If the bitmask bit is 1, the corresponding memory address bit is overwritten with 1.
    # If the bitmask bit is X, the corresponding memory address bit is floating.

    for line in lines:
        var kv = line.split('=')
        if kv[0] == "mask ":
            var maskstr = kv[1].strip
            if maskstr.replace('1', '0').replace('X', '1').parseBin(maskWc) != 36:
                echo("bin? ", kv)
            if maskstr.replace('X', '0').parseBin(maskOr) != 36:
                echo("bin? ", kv)
        elif scanf(line, "mem[${valmatcher}] = ${valmatcher}", address, value):
            var adr = (address or maskOr) and (not maskWc)
            muck2(adr, value, maskWc)
        else:
            echo("wtf: ", line, " ", kv[1])
    for x in memory.values:
        result += x


echo("Part 2 ex: ", part2("""mask = 000000000000000000000000000000X1001X
mem[42] = 100
mask = 00000000000000000000000000000000X0XX
mem[26] = 1
"""))

echo("Part 2: ", part2(input))
