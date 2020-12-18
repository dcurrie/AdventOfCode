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

# https://en.wikipedia.org/wiki/Operator-precedence_parser#Alternative_methods
# The Fortran I compiler would expand each operator with a sequence of parentheses. In a simplified form of the algorithm, it would
# replace + and – with ))+(( and ))-((, respectively;
# replace * and / with )*( and )/(, respectively;
# add (( at the beginning of each expression and after each left parenthesis in the original expression; and
# add )) at the end of the expression and before each right parenthesis in the original expression.

proc reparen(input: string): string =
    result.add("((")
    for c in input:
        case c:
        of ' ':
            discard
        of '(':
            result.add("(((")
        of ')':
            result.add(")))")
        of '+':
            result.add(")+(")
        of '*':
            result.add("))*((")
        else:
            result.add(c)
    result.add("))")

proc part2(input: string): int =
    for line in input.strip.splitLines:
        result += eval(reparen(line))

proc part2x(input: string): int =
    for line in input.strip.splitLines:
        var s = reparen(line)
        echo s
        result += eval(s)

echo("Part 2 ex 1: ", part2x("2 * 3 + (4 * 5)"))
echo("Part 2 ex 2: ", part2("5 + (8 * 3 + 9 + 3 * 4 * 3)"))
echo("Part 2 ex 3: ", part2("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"))
echo("Part 2 ex 4: ", part2("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"))

echo("Part 2: ", part2(input))
