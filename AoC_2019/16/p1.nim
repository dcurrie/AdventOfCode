import strutils, sequtils, strscans, os, tables, math

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "in1.txt"
    input = readFile(fname)

proc parsein(inp: string): seq[int8] =
    for c in inp:
        if c >= '0' and c <= '9':
            result.add c.int8 - '0'.int8

const pattern = [0, 1, 0, -1]

proc step(n: int, sig: seq[int8]): int8 =
    var repeat = 1
    var patidx = 0
    var temp = 0
    for v in sig:
        if repeat < n:
            repeat += 1
        else:
            repeat = 1
            patidx = (patidx + 1) mod 4
        #echo (v, pattern[patidx])
        temp += v.int * pattern[patidx]
    #echo temp
    result = (abs(temp) mod 10).int8


proc part1a(n: int, sig: seq[int8]): seq[int8] =
    var sigv = sig
    for phase in 1..n:
        result = @[]
        for n in 1..sig.len:
            result.add step(n, sigv)
        #echo result
        sigv = result

proc part1(n: int, sig: seq[int8]): string = 
    let v = part1a(n, sig)
    for i in 0..7:
        result.add((v[i] + '0'.int8).char)

when defined(test1):
    #echo parsein("0123456789")
    echo part1(4, parsein("12345678"))
    echo part1(100, parsein("80871224585914546619083218645595"))
    echo part1(100, parsein("19617804207202209144916044189917"))
    echo part1(100, parsein("69317163492948606335995924319873"))

# echo part1(100, parsein(input)) # 19944447

proc part2brute(n: int, sig: seq[int8]): string = 
    let o = (((((((((((sig[0].int  * 10) +
                       sig[1].int) * 10) +
                       sig[2].int) * 10) +
                       sig[3].int) * 10) +
                       sig[4].int) * 10) +
                       sig[5].int) * 10) + sig[6].int
    let v = part1a(n, cycle(sig, 10000))
    for i in 0..7:
        result.add((v[o+i] + '0'.int8).char)


proc part2a(n: int, o: int, sig: seq[int8]): seq[int8] =
    var sigv = sig
    for phase in 1..n:
        for n in countdown(sig.len - 2, sig.len - o):
            sigv[n] = (sigv[n] + sigv[n+1]) mod 10
        result = sigv

proc part2(n: int, sig: seq[int8]): string = 
    let o = (((((((((((sig[0].int  * 10) +
                       sig[1].int) * 10) +
                       sig[2].int) * 10) +
                       sig[3].int) * 10) +
                       sig[4].int) * 10) +
                       sig[5].int) * 10) + sig[6].int
    echo "Offset: ", o
    let v = part2a(n, o, cycle(sig, 10000))
    for i in 0..7:
        result.add((v[o+i] + '0'.int8).char)


when defined(test2):
    echo part2(100, parsein("03036732577212944063491565474664"))
    echo part2(100, parsein("02935109699940807407585447034323"))
    echo part2(100, parsein("03081770884921959731165446850517"))
    #for i in countdown(3,1): echo i

echo part2(100, parsein(input))
