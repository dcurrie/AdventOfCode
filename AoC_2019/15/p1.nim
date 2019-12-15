import strutils, sequtils, strscans, os, tables, sets, algorithm, unicode

import ../../Utils/dijkstra
import ../../Utils/dgraph
import ../../Utils/daryheap

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "in1.txt"
    input = readFile(fname).splitLines

type vm = object
    pgm: seq[int]
    pc: int
    base: int
    halted: bool
    toggle: int
    input: seq[int]
    output: seq[int]

proc initvm(input: seq[int]): vm =
    result = vm(pgm: input,
                pc: 0,
                base: 0,
                halted: false,
                toggle: 0,
                input: @[],
                output: @[])

proc resetvm(m: var vm) =
    m.pc = 0
    m.base = 0
    m.halted = false
    m.toggle = 0
    #m.input = @[]  # ??
    m.output = @[]

proc checkLen(m: var vm, offs: int) =
    if m.pgm.len <= offs:
        setLen(m.pgm, offs + 1)

proc decode(opin: int): (int, int, int, int) =
    var op = opin
    let opc = op mod 100
    op = op div 100
    let amode = op mod 10
    op = op div 10
    let bmode = op mod 10
    op = op div 10
    let cmode = op mod 10
    return (opc, amode, bmode, cmode)

proc fetch(m: var vm, mode: int, parm: int): int = 
    if mode == 0:
        checkLen(m, parm)
        result = m.pgm[parm]
    elif mode == 1:
        result = parm
    elif mode == 2:
        checkLen(m, parm + m.base)
        result = m.pgm[parm + m.base]
    else:
        echo "Attempt to fetch in unknown mode ", mode, " ", parm

proc store(m: var vm, mode: int, parm: int, val: int) = 
    if mode == 0:
        checkLen(m, parm)
        m.pgm[parm] = val
    elif mode == 1:
        echo "Attempt to store in immediate mode ", parm, " ", val
        discard
    elif mode == 2:
        checkLen(m, parm + m.base)
        m.pgm[parm + m.base] = val
    else:
        echo "Attempt to store in unknown mode ", mode, " ", parm, " ", val
        discard

var trace = false
var verbo = false

type 
    Tile = enum Unknown, Empty, Wall, Oxygen
    Locn = tuple [x: int, y: int]

var robot: Locn
var oxylocn: Locn

var world = initTable[Locn, Tile]()

var minx: int
var miny: int
var maxx: int
var maxy: int

proc checkmm() = 
    minx = min(minx, robot.x)
    maxx = max(maxx, robot.x)
    miny = min(miny, robot.y)
    maxy = max(maxy, robot.y)

proc display_world() =
    echo "World ", (minx, maxx), (miny, maxy), " driod: ", robot, " Oxygen: ", oxylocn
    var outstr: string
    for y in miny..maxy:
        for x in minx..maxx:
            var ochar:Rune = "░".runeAt(0)
            let key = (x,y)
            if key == robot:
                ochar = "R".runeAt(0)
            elif world.hasKey(key):
                ochar = case world[key]
                        of Empty: " ".runeAt(0)
                        of Unknown: "░".runeAt(0)
                        of Wall: "█".runeAt(0)
                        of Oxygen: "O".runeAt(0)
            outstr.add(ochar)
        outstr.add("\n ".runeAt(0))
    echo(outstr)

proc pgm_input(m: var vm): int = 
    return m.input.pop

proc run2o(m: var vm): int = 
    result = int.low
    var pc = m.pc
    var (op, amode, bmode, cmode) = decode(m.pgm[pc])
    if trace: echo "@", pc, (op, amode, bmode, cmode), m.pgm[pc+1], ",", m.pgm[pc+2], ",", m.pgm[pc+3]
    while op != 99:
        case op 
        of 1:
            let a = fetch(m, amode, m.pgm[pc+1])
            let b = fetch(m, bmode, m.pgm[pc+2])
            let c = m.pgm[pc+3]
            if trace: echo 1, (a, b, c)
            store(m, cmode, c, a + b)
            pc += 4
        of 2:
            let a = fetch(m, amode, m.pgm[pc+1])
            let b = fetch(m, bmode, m.pgm[pc+2])
            let c = m.pgm[pc+3]
            if trace: echo 2, (a, b, c)
            store(m, cmode, c, a * b)
            pc += 4
        of 3:
            # let a = pgm[pc+1]
            # pgm[a] = pgm_input()
            let inp = pgm_input(m)
            store(m, amode, m.pgm[pc+1], inp)
            if trace: echo 3, (m.pgm[pc+1], inp)
            pc += 2
        of 4:
            let a = fetch(m, amode, m.pgm[pc+1])
            #pgm_output(m, a)
            pc += 2
            m.pc = pc
            return a
        of 5:
            let a = fetch(m, amode, m.pgm[pc+1])
            let b = fetch(m, bmode, m.pgm[pc+2])
            if trace: echo 5, (a, b)
            if a != 0:
                pc = b
            else:
                pc += 3
        of 6:
            let a = fetch(m, amode, m.pgm[pc+1])
            let b = fetch(m, bmode, m.pgm[pc+2])
            if a == 0:
                pc = b
            else:
                pc += 3
        of 7:
            let a = fetch(m, amode, m.pgm[pc+1])
            let b = fetch(m, bmode, m.pgm[pc+2])
            let c = m.pgm[pc+3]
            store(m, cmode, c, if a < b: 1 else: 0)
            pc += 4
        of 8:
            let a = fetch(m, amode, m.pgm[pc+1])
            let b = fetch(m, bmode, m.pgm[pc+2])
            let c = m.pgm[pc+3]
            store(m, cmode, c, if a == b: 1 else: 0)
            pc += 4
        of 9:
            let a = fetch(m, amode, m.pgm[pc+1])
            m.base += a
            pc += 2
        else:
            echo "Bad op ", op, " at ", pc
            m.pc = pc
            m.halted = true
            return int.high
        (op, amode, bmode, cmode) = decode(m.pgm[pc])
        if trace: echo "@", pc, (op, amode, bmode, cmode), m.pgm[pc+1], ",", m.pgm[pc+2], ",", m.pgm[pc+3]
    m.halted = true


# direction: north (1), south (2), west (3), and east (4)

proc move(direction: int) = 
    robot.x += (if direction == 3: -1 elif direction == 4: 1 else: 0)
    robot.y += (if direction == 1: -1 elif direction == 2: 1 else: 0)

proc back(direction: int) =
    robot.x += (if direction == 3: 1 elif direction == 4: -1 else: 0)
    robot.y += (if direction == 1: 1 elif direction == 2: -1 else: 0)

proc reversedir(x: int): int =
    case x
    of 1: 2
    of 2: 1
    of 3: 4
    of 4: 3
    else: 0

proc part1run(m: var vm, stepin: int) =
    var choice = 0
    while not m.halted and choice < 4:
        choice += 1
        move(choice)
        case world.getOrDefault(robot)
        of Unknown:
            checkmm()
            m.input.add(choice)
            case run2o(m)
            of 0: # wall
                if verbo: echo "Wall at ", robot
                world[robot] = Wall
                back(choice)
            of 1: # step
                world[robot] = Empty
                part1run(m, choice)
            of 2: # oxygen
                world[robot] = Oxygen
                oxylocn = robot
                part1run(m, choice)
            else:
                echo "Unknown output "
                m.halted = true
        of Wall:
            back(choice)
        of Empty:
            back(choice)
        of Oxygen:
            if verbo: echo "Found Oxygen again!", robot
            back(choice)
    # back up
    if m.halted or stepin == 0:
        return
    m.input.add(reversedir(stepin))
    assert(run2o(m) != 0)
    back(stepin)

proc readin(): seq[int] =
    var pgm: seq[int]
    for line in input:
        if line != "":
            var codes = line.split(',')
            for s in codes:
                pgm.add(parseInt(s))
    return pgm

proc part1(): (int, int) = 
    verbo = true
    world[robot] = Empty
    var m = initvm(readin())
    part1run(m, 0)
    if m.halted: echo "Halted!"
    display_world()
    # find path
    var g = DGraph[Locn,int]()
    for y in miny..(maxy-1):
        for x in minx..(maxx-1):
            let fmkey = (x,y)
            let fmtyp = world.getOrDefault(fmkey)
            if fmtyp != Wall and fmtyp != Unknown:
                let rtkey = (x,y+1)
                let rttyp = world.getOrDefault(rtkey)
                let dnkey = (x+1,y)
                let dntyp = world.getOrDefault(dnkey)
                if rttyp != Wall and rttyp != Unknown:
                    let _ = g.add_edges(@[(fmkey, rtkey, 1),(rtkey, fmkey, 1)])
                if dntyp != Wall and dntyp != Unknown:
                    let _ = g.add_edges(@[(fmkey, dnkey, 1),(dnkey, fmkey, 1)])
    let (dist, prev) = g.dijkstra((0,0))
    #return dist[oxylocn] # part 1
    let (diso, preo) = g.dijkstra(oxylocn)
    var x = int.low
    for d in diso.values():
        x = x.max d
    return (dist[oxylocn], x)

#echo "Part 1, distance to oxygen: ", part1()

let (d, t) = part1()
echo "Part 1, distance to oxygen: ", d
echo "Part 2, time to fulloxygen: ", t
