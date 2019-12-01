
import strutils, sequtils, strscans, os

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "in1.txt"
    input = readFile(fname).splitLines

#echo("Params: ", params)

proc part1() =
    var sum = 0
    for line in input:
        var mass: int
        #var l, r: string
        if scanf(line, "$i", mass):
            sum = sum + ((mass /% 3) - 2)
    echo("Part 1: ", sum)

part1()

proc part2() =
    var sum = 0
    for line in input:
        var mass, fuel: int
        #var l, r: string
        if scanf(line, "$i", mass):
            fuel = ((mass /% 3) - 2)
            while fuel > 0:
                sum = sum + fuel
                fuel = ((fuel /% 3) - 2)
    echo("Part 2: ", sum)

part2()
