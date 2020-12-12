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

# Almost all of the actions indicate how to move a waypoint which is relative to the ship's position:
# Action N means to move the waypoint north by the given value.
# Action S means to move the waypoint south by the given value.
# Action E means to move the waypoint east by the given value.
# Action W means to move the waypoint west by the given value.
# Action L means to rotate the waypoint around the ship left (counter-clockwise) the given number of degrees.
# Action R means to rotate the waypoint around the ship right (clockwise) the given number of degrees.
# Action F means to move forward to the waypoint a number of times equal to the given value.
# The waypoint starts 10 units east and 1 unit north relative to the ship.
# The waypoint is relative to the ship; that is, if the ship moves, the waypoint moves with it.

proc degrect(deg: float64): Complex[float64] =
    case deg:
    of  90.0: complex[float64](0, 1)
    of 180.0: complex[float64](-1, 0)
    of 270.0: complex[float64](0, -1)
    of 360.0: complex[float64](1, 0)
    else: echo("degrect ", deg); complex[float64](1, 0)

proc part2(input: string): int =
    var wpt = complex[float64](10, 1)
    var pos = complex[float64](0, 0)
    for s in input.strip.splitLines:
        var val = parseFloat(s.substr(1))
        case s[0]
        of 'N': wpt += complex[float64](0,val)
        of 'S': wpt += complex[float64](0,-val)
        of 'E': wpt += complex[float64](val,0)
        of 'W': wpt += complex[float64](-val,0)
        of 'L': wpt *= degrect(val)
        of 'R': wpt *= degrect(360 - val)
        of 'F': pos += wpt * val
        else: discard
    echo(wpt, pos)
    return abs(pos.re).toInt + abs(pos.im).toInt

echo("Part 2: ", part2("""F10
N3
F7
R90
F11"""))

echo("Part 2: ", part2(input))
