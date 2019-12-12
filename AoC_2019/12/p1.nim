import strutils, sequtils, strscans, os, tables, math

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "in1.txt"
    input = readFile(fname)


const
    qbodies = 4

type
    moon = tuple [x: int, y: int, z: int, dx: int, dy: int, dz: int]

var
    moons: array[0..(qbodies-1), moon]


proc readin(input: string): array[0..3, moon] =
    var n = 0
    for line in input.splitLines:
        var x, y, z: int
        if scanf(line, "<x=$i, y=$i, z=$i>", x, y, z):
            result[n] = (x, y, z, 0, 0, 0)
            n += 1

proc step() =
    #var moont: array[0..(qbodies-1), moon]
    #moont = moons # copy
    var moont = moons # copy
    # apply gravity
    for i in 0..(qbodies-1):
        for j in i..(qbodies-1):
            if moont[i].x < moont[j].x:
                moont[i].dx += 1
                moont[j].dx -= 1
            elif moont[i].x > moont[j].x:
                moont[j].dx += 1
                moont[i].dx -= 1
            else:
                discard
            if moont[i].y < moont[j].y:
                moont[i].dy += 1
                moont[j].dy -= 1
            elif moont[i].y > moont[j].y:
                moont[j].dy += 1
                moont[i].dy -= 1
            else:
                discard
            if moont[i].z < moont[j].z:
                moont[i].dz += 1
                moont[j].dz -= 1
            elif moont[i].z > moont[j].z:
                moont[j].dz += 1
                moont[i].dz -= 1
            else:
                discard
    # apply velocity
    for i in 0..(qbodies-1):
        moont[i].x += moont[i].dx
        moont[i].y += moont[i].dy
        moont[i].z += moont[i].dz
    moons = moont

proc calcEnergy(): int = 
    for i in 0..(qbodies-1):
        let pot = abs(moons[i].x)  + abs(moons[i].y)  + abs(moons[i].z)
        let kin = abs(moons[i].dx) + abs(moons[i].dy) + abs(moons[i].dz)
        result += pot * kin

proc doSteps(n: int): int = 
    for i in 1..n:
        step()
    result = calcEnergy()

proc displayMoons() =
    for i in 0..(qbodies-1):
        echo moons[i]

when defined(test1):
    #moons = readin(input)
    #echo moons
    moons = readin("<x=-1, y=0, z=2>\n<x=2, y=-10, z=-7>\n<x=4, y=-8, z=8>\n<x=3, y=5, z=-1>")
    echo "After ", 0, " steps:"
    displayMoons()
    echo ""
    for i in 0..9:
        step()
        echo "After ", i+1, " steps:"
        displayMoons()
        echo ""
    echo "Total energy: ", calcEnergy()

    moons = readin("<x=-8, y=-10, z=0>\n<x=5, y=5, z=10>\n<x=2, y=-7, z=3>\n<x=9, y=-8, z=-3>")
    echo "After ", 0, " steps:"
    displayMoons()
    echo ""
    for i in 1..100:
        step()
        if i mod 10 == 0:
            echo "After ", i, " steps:"
            displayMoons()
            echo ""
    echo "Total energy: ", calcEnergy()

proc part1() =
    moons = readin(input)
    echo "Part 1: ", doSteps(1000)

part1()

proc part2a(): int = 
    var states = initTable[array[0..(qbodies-1), moon], bool]()
    moons = readin(input)
    states[moons] = true
    while true:
        step()
        result += 1
        if states.hasKey(moons):
            break
        else:
            states[moons] = true

proc part2b(): (int, int, int, int) = 
    var xstates = initTable[(int, int, int, int, int, int, int, int), int]()
    var ystates = initTable[(int, int, int, int, int, int, int, int), int]()
    var zstates = initTable[(int, int, int, int, int, int, int, int), int]()
    moons = readin(input)
    xstates[(moons[0].x,  moons[1].x,  moons[2].x,  moons[3].x,
             moons[0].dx, moons[1].dx, moons[2].dx, moons[3].dx)] = 0
    ystates[(moons[0].y,  moons[1].y,  moons[2].y,  moons[3].y,
             moons[0].dy, moons[1].dy, moons[2].dy, moons[3].dy)] = 0
    zstates[(moons[0].z,  moons[1].z,  moons[2].z,  moons[3].z,
             moons[0].dz, moons[1].dz, moons[2].dz, moons[3].dz)] = 0
    var (xoff, xper) = (0, 0)
    var (yoff, yper) = (0, 0)
    var (zoff, zper) = (0, 0)
    var n = 0
    while xper == 0 or yper == 0 or zper == 0:
        step()
        n += 1
        if xper == 0:                                   # the bug was here, was using !=
            let xkey = (moons[0].x,  moons[1].x,  moons[2].x,  moons[3].x,
                        moons[0].dx, moons[1].dx, moons[2].dx, moons[3].dx)
            if xstates.hasKey(xkey):
                xoff = n
                xper = n - xstates[xkey]
                echo "X match at: ", xoff, " period: ", xper
            else:
                xstates[xkey] = n
        if yper == 0:                                   # the bug was here, was using !=
            let ykey = (moons[0].y,  moons[1].y,  moons[2].y,  moons[3].y,
                        moons[0].dy, moons[1].dy, moons[2].dy, moons[3].dy)
            if ystates.hasKey(ykey):
                yoff = n
                yper = n - ystates[ykey]
                echo "Y match at: ", yoff, " period: ", yper
            else:
                ystates[ykey] = n
        if zper == 0:                                   # the bug was here, was using !=
            let zkey = (moons[0].z,  moons[1].z,  moons[2].z,  moons[3].z,
                        moons[0].dz, moons[1].dz, moons[2].dz, moons[3].dz)
            if zstates.hasKey(zkey):
                zoff = n
                zper = n - zstates[zkey]
                echo "Z match at: ", zoff, " period: ", zper
            else:
                zstates[zkey] = n
    return (xper, yper, zper, lcm(lcm(xper, yper), zper))

proc part2(): (int, int, int, int) = 
    #moons = readin(input)
    let moon0 = deepCopy(moons) # state 0
    #displayMoons()
    var xper = 0
    var yper = 0
    var zper = 0
    var n = 0
    while xper == 0 or yper == 0 or zper == 0:
        step()
        n += 1
        if xper == 0:                                   # the bug was here, was using !=
            if (    moons[0].x  == moon0[0].x  and  
                    moons[1].x  == moon0[1].x  and
                    moons[2].x  == moon0[2].x  and
                    moons[3].x  == moon0[3].x  and
                    moons[0].dx == moon0[0].dx and
                    moons[1].dx == moon0[1].dx and
                    moons[2].dx == moon0[2].dx and
                    moons[3].dx == moon0[3].dx):
                xper = n
                echo "X match at: ", xper
        if yper == 0:                                   # the bug was here, was using !=
            if (    moons[0].y  == moon0[0].y  and  
                    moons[1].y  == moon0[1].y  and
                    moons[2].y  == moon0[2].y  and
                    moons[3].y  == moon0[3].y  and
                    moons[0].dy == moon0[0].dy and
                    moons[1].dy == moon0[1].dy and
                    moons[2].dy == moon0[2].dy and
                    moons[3].dy == moon0[3].dy):
                yper = n
                echo "Y match at: ", yper
        if zper == 0:                                   # the bug was here, was using !=
            if (    moons[0].z  == moon0[0].z  and  
                    moons[1].z  == moon0[1].z  and
                    moons[2].z  == moon0[2].z  and
                    moons[3].z  == moon0[3].z  and
                    moons[0].dz == moon0[0].dz and
                    moons[1].dz == moon0[1].dz and
                    moons[2].dz == moon0[2].dz and
                    moons[3].dz == moon0[3].dz):
                zper = n
                echo "Z match at: ", zper
        #if n mod 1000 == 0:
        #    echo "Steps: ", n
    return (xper, yper, zper, lcm(lcm(xper, yper), zper))

when defined(test2):
    moons = readin("<x=-1, y=0, z=2>\n<x=2, y=-10, z=-7>\n<x=4, y=-8, z=8>\n<x=3, y=5, z=-1>")
    echo "Part 2: ", part2()

moons = readin(input)
echo "Part 2: ", part2()  # 318382803780324


# it really worked all along...
#echo "Part 2b: ", part2b()
#[
Part 2: (28482, 231614, 193052, 318382803780324)
X match at: 28482 period: 28482
Z match at: 193052 period: 193052
Y match at: 231614 period: 231614
Part 2b: (28482, 231614, 193052, 318382803780324)
]#
