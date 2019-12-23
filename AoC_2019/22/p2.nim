import strutils, strscans, os

import stint # for i128 and i256

# Thanks to stint
# Thanks to https://github.com/gernb/AdventOfCode2019/blob/master/Day%2022/Day%2022/main.swift
# Thanks to https://www.reddit.com/r/adventofcode/comments/ee0rqi/2019_day_22_solutions/fbnifwk/

# I can only take credit for learning something about stint and translating the Swift code to Nim 

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "in1.txt"
    input = readFile(fname)

const
# int.high 9_223_372_036_854_775_807
    qcards     = 119_315_717_514_047.int
    repeats    = 101_741_582_076_661.int

proc power(x, y, m: int): int =
    if y == 0:
        return 1
    var p = power(x, y div 2, m) mod m
    p = ((p.i128 * p.i128) mod m.i128).truncate(int)
    return if (y and 1) == 0: p  else: ((x.i128 * p.i128) mod m.i128).truncate(int)

proc primeModInverse(a, m: int): int =
    return power(a, m - 2, m)

#[
 X = 2020
 Y = f(X)
 Z = f(Y)
 A = (Y-Z) * modinv(X-Y+D, D) % D
 B = (Y-A*X) % D
]#

proc part2(input: string): int =

    var X = 2020
    var Y = X

    for line in input.rsplit("\n"):
        var q: int
        if scanf(line, "deal into new stack"):
            # reverse sequence
            Y = qcards - 1 - Y
        elif scanf(line, "cut $i", q):
            # shift q left
            Y = (Y + q + qcards) mod qcards
        elif scanf(line, "deal with increment $i", q):
            Y = ((primeModInverse(q, qcards).i128 * Y.i128) mod qcards.i128).truncate(int)
        elif line == "":
            discard
        else:
            echo "Wtf: ", line
    
    var Z = Y

    #echo "Y: ", Y, if Y == 8150301316572.int: " ok" else: " ng"

    for line in input.rsplit("\n"):
        var q: int
        if scanf(line, "deal into new stack"):
            # reverse sequence
            Z = qcards - 1 - Z
        elif scanf(line, "cut $i", q):
            # shift q left
            Z = (Z + q + qcards) mod qcards
        elif scanf(line, "deal with increment $i", q):
            Z = ((primeModInverse(q, qcards).i128 * Z.i128) mod qcards.i128).truncate(int)
        elif line == "":
            discard
        else:
            echo "Wtf: ", line

    #echo "Z: ", Z, if Z == 74518628734685.int: " ok" else: " ng" 

    let D = qcards
    let n = repeats

    let A = ((Y - Z).i128 * primeModInverse(X - Y + D, D).i128 mod D.i128).truncate(int)
    #echo "A: ", A, if A == -25975498786348.int: " ok" else: " ng" 

    let B = ((Y.i128 - A.i128 * X.i128) mod D.i128).truncate(int)
    #echo "B: ", B, if B == 99057861072899.int: " ok" else: " ng" 

    #echo (power(A, n, D).i128 * X.i128) == -221703938561232260.i128
    #echo (power(A, n, D).i128 - 1.i128) == -109754425030314.i128
    #echo (primeModInverse(A - 1, D)) == -104902379160278.int
    #echo (power(A, n, D).i256 - 1.i256) * primeModInverse(A - 1, D).i256 * B.i256 == "1140502714076486742780523501718599642919508".i256

    return ((power(A, n, D).i256 * X.i256 + 
            (power(A, n, D).i256 - 1.i256) * primeModInverse(A - 1, D).i256 * B.i256) mod D.i256).truncate(int)

echo "Part 2: ", part2(input) # 64586600795606
