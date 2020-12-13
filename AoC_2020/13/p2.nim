import strutils, sequtils, strscans, os, sets, tables, parseutils, math, sugar

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "input.txt"
    input = readFile(fname)

#echo("Params: ", params)

# 67,7,59,61 first occurs at timestamp 754018
# 754018 mod 67 ==      0
# 754018 mod  7 ==  7 - 1
# 754018 mod 59 == 59 - 2
# 754018 mod 61 == 61 - 3
# check:
#   echo(754018 mod 67, " ", 754018 mod 7, " ", 754018 mod 59, " ", 754018 mod 61)
# 0 6 57 58

# t mod id0 = 0
# t mod idN = (idN - N)
# so, take the largest idN, iterate multiples, and check

proc part2a(input: string): int64 =
    var lines = input.strip.splitLines
    var line = lines[1].split(',')
    var ids: seq[tuple[n: int, id: int]]
    var maxid = -1
    var maxidn: int
    for n, idstr in line.pairs:
        var id: int
        if parseutils.parseInt(idstr, id) > 0:
            ids.add((n,id))
            if id > maxid:
                maxid = id
                maxidn = n
    #echo(ids, " ", maxidn, " ", maxid)
    for m in 1..100000000000000000:
        var t = maxid * m + (maxid - maxidn)
        if ids.allIt(t mod it.id == (if it.n == 0: 0 else: it.id - it.n)):
            return t

echo("Par 2 ex1: ", part2a("""x
17,x,13,19"""))
echo("Par 2 ex2: ", part2a("""x
67,7,59,61"""))



#  N = idN - nN
#  d0 * m0 == t
#  d1 * m1 + k1 == t
#  d2 * m2 + k2 == t
#
#  d0 * m0 == id1 * m1 + k1
#  0 == (id1 * m1 + k1) / id0 => (id1 * m1) mod id0 == k1
#
# OK, so this means the Chinese Remainder Theorem

proc extended_gcd(a: int64, b: int64): (int64, int64, int64, int64, int64) =
    var s:int64 = 0
    var old_s:int64 = 1
    var t:int64 = 1
    var old_t:int64 = 0
    var r:int64 = b
    var old_r:int64 = a

    while r != 0:
        let quotient:int64 = floorDiv(old_r, r)
        (old_r, r) = (r, old_r - quotient * r)
        (old_s, s) = (s, old_s - quotient * s)
        (old_t, t) = (t, old_t - quotient * t)

    return (old_r, old_s, old_t, t, s)

type
    Busses = seq[tuple[n: int, id: int64, rem: int64]]

proc crt(xys: Busses): (bool, int64) =
    var p:int64 = xys.foldl(a * b.id, int64(1))
    var r:int64 = 0
    for b in xys:
        var x = b.id
        var y = b.rem
        let q = floorDiv(p, x)
        let (z,s,t,qt,qs) = q.extended_gcd(x)
        if z != 1:
            return (false, x)
        if s < 0: r += y * (s + x) * q
        else:     r += y * s       * q
    return (true, r mod p)


proc part2(input: string): int64 =
    var lines = input.strip.splitLines
    var line = lines[1].split(',')
    var ids: Busses
    var maxid: int64 = -1
    var maxidn: int
    for n, idstr in line.pairs:
        var id: int
        if parseutils.parseInt(idstr, id) > 0:
            ids.add((n, int64(id), int64(if n == 0: 0 else: id - n)))
            if id > maxid:
                maxid = id
                maxidn = n
    #echo(ids, " ", maxidn, " ", maxid)
    let (ok,t) = crt(ids)
    result = t
    if not ok:
        echo "Fail!"

echo("Part 2 ex1: ", part2("""x
17,x,13,19"""))
echo("Part 2 ex2: ", part2("""x
67,7,59,61"""))

echo("Part 2: ", part2(input))

