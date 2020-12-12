import strutils, sequtils, strscans, os, tables, sets, algorithm, complex

let
    params = commandLineParams()
    fname = if params.len > 0: params[0] else: "input.txt"
    input = readFile(fname)

# Locn is a Complex64
# N 1 = i
# E 1 = 1
# S 1 = -i
# W 1 = -1

# Action N means to move north by the given value.
# Action S means to move south by the given value.
# Action E means to move east by the given value.
# Action W means to move west by the given value.
# Action L means to turn left the given number of degrees.
# Action R means to turn right the given number of degrees.
# Action F means to move forward by the given value in the direction the ship is currently facing.

proc degrect(deg: float64): Complex[float64] =
    case deg:
    of  90.0: complex[float64](0, 1)
    of 180.0: complex[float64](-1, 0)
    of 270.0: complex[float64](0, -1)
    of 360.0: complex[float64](1, 0)
    else: echo("degrect ", deg); complex[float64](1, 0)

proc part1(input: string): int =
    var dir = complex[float64](1, 0)
    var pos = complex[float64](0, 0)
    for s in input.strip.splitLines:
        var val = parseFloat(s.substr(1))
        case s[0]
        of 'N': pos += complex[float64](0,val)
        of 'S': pos += complex[float64](0,-val)
        of 'E': pos += complex[float64](val,0)
        of 'W': pos += complex[float64](-val,0)
        of 'L': dir *= degrect(val)
        of 'R': dir *= degrect(360 - val)
        of 'F': pos += dir * val
        else: discard
    echo(dir, pos)
    return abs(pos.re).toInt + abs(pos.im).toInt

echo("Part 1: ", part1("""F10
N3
F7
R90
F11"""))

echo("Part 1: ", part1(input))
