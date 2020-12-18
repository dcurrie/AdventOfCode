import strutils, sequtils, strscans, os, sets, tables, parseutils, sugar

let
    params = commandLineParams()
    fname = if params.len > 0 : params[0] else : "input.txt"
    input = readFile(fname)

#echo("Params: ", params)

proc eval(line: string): int =
    var ops: seq[char]
    var stk: seq[int]
    ops.add('(')
    stk.add(0)
    proc app(x: int): int =
        var c = ops.pop
        case c:
        of '(':
            return x
        of '+':
            return stk.pop + x
        of '*':
            return stk.pop * x
        else:
            return x
    for c in line:
        if c == ' ':
            discard
        elif c == '(' or c == '+' or c == '*':
            ops.add(c)
        elif c == ')':
            stk.add(app(stk.pop))
        elif c.isDigit:
            stk.add(app(int(c) - int('0')))
        else:
            ops.add(c)
    return stk.pop

proc part1(input: string): int =
    for line in input.strip.splitLines:
        result += eval(line)

echo("Part 1 ex 1: ", part1("2 * 3 + (4 * 5)"))
echo("Part 1 ex 2: ", part1("5 + (8 * 3 + 9 + 3 * 4 * 3)"))
echo("Part 1 ex 3: ", part1("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"))
echo("Part 1 ex 4: ", part1("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"))

echo("Part 1: ", part1(input))
