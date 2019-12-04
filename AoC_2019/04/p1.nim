

let rangelo: uint = 178416'u
let rangehi: uint = 676461'u

proc num2digs(n: uint, ds: var seq[uint]): seq[uint] =
    let d = n mod 10'u
    let r = n div 10'u
    result = ds
    if r != 0'u:
        result = num2digs(r, ds)
    result.add(d)

proc checknum(n: uint): bool = 
    var digs: seq[uint] = @[]
    digs = num2digs(n, digs)
    #echo(digs)
    # It is a six-digit number.
    if digs.len != 6: return false
    # The value is within the range given in your puzzle input.
    # -- by design
    # Two adjacent digits are the same (like 22 in 122345).
    # Going from left to right, the digits never decrease; they only ever increase or stay the same (like 111123 or 135679)
    var d = digs[0]
    var p = false
    var u = true
    for i in 1..5:
        if digs[i] == d: p = true
        if digs[i] < d:  u = false
        d = digs[i]
    result = p and u

when defined(test1):
    doAssert(checknum(111111'u) == true)
    doAssert(checknum(223450'u) == false)
    doAssert(checknum(123789'u) == false)

proc part1(): int =
    result = 0
    for n in rangelo..rangehi:
        if checknum(n): result += 1

#echo("Part 1: ", part1())

proc checknum2(n: uint): bool = 
    var digs: seq[uint] = @[]
    digs = num2digs(n, digs)
    #echo(digs)
    # It is a six-digit number.
    if digs.len != 6: return false
    # The value is within the range given in your puzzle input.
    # -- by design
    # Two adjacent digits are the same (like 22 in 122345).
    # Going from left to right, the digits never decrease; they only ever increase or stay the same (like 111123 or 135679)
    # Part2: the two adjacent matching digits are not part of a larger group of matching digits
    var d = digs[0]
    var p = false
    var s = false
    var c = 1
    var u = true
    for i in 1..5:
        if digs[i] == d:
            c += 1
            if c == 2: p = true
            if c  > 2: p = false
        else:
            if p: s = p
            c = 1
        if digs[i] < d:  u = false
        d = digs[i]
    result = (s or p) and u


when defined(test2):
    doAssert(checknum2(112233'u) == true)
    doAssert(checknum2(123444'u) == false)
    doAssert(checknum2(111122'u) == true)
    doAssert(checknum2(112222'u) == true) # added to confirm the issue with 1st attempt (941)

proc part2(): int =
    result = 0
    for n in rangelo..rangehi:
        if checknum2(n): result += 1

echo("Part 2: ", part2())
# 941 is wrong -- had to add s "sticky" variable so later groups didn't invalidate earlier ones
