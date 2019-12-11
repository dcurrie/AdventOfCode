import strutils, sequtils, strscans, os, tables, algorithm

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "in1.txt"
    input = readFile(fname).splitLines

#echo("Params: ", params)

type vm = object
    pgm: seq[int]
    pc: int
    base: int
    halted: bool
    toggle: bool
    input: seq[int]
    output: seq[int]

proc initvm(input: seq[int]): vm =
    result = vm(pgm: input,
                pc: 0,
                base: 0,
                halted: false,
                toggle: false,
                input: @[],
                output: @[])

proc resetvm(m: var vm) =
    m.pc = 0
    m.base = 0
    m.halted = false
    m.toggle = false
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

#[
proc pgm_input(m: var vm): int = 
    if m.toggle:
        result = m.output.pop()
    else:
        result = m.input.pop()
        m.toggle = true

proc pgm_output(m: var vm, i: int) =
    #echo "Output added ", i
    m.output.add(i)
]#

type 
    Color = enum Black, White
    Locn = tuple [x: int, y: int]

var robot: Locn
var direction: Locn = (0,-1)

proc rotLeft() = direction = (direction.y, -direction.x)  # (0,-1) (-1,0) ( 0,1) (1, 0)
proc rotRight() = direction = (-direction.y, direction.x) # (1, 0) ( 0,1) (-1,0) (0,-1)

var minx: int
var miny: int
var maxx: int
var maxy: int

proc checkmm() = 
    minx = min(minx, robot.x)
    maxx = max(maxx, robot.x)
    miny = min(miny, robot.y)
    maxy = max(maxy, robot.y)

proc move() = 
    robot.x += direction.x
    robot.y += direction.y
    checkmm() # added part 2

var world = initTable[Locn, Color]()

proc pgm_input(m: var vm): int = 
    if world.hasKey(robot):
        result = ord(world[robot])
    else:
        result = ord(Color.Black)

proc pgm_output(m: var vm, i: int) =
    if m.toggle:
        if i == 0: rotLeft()
        else: rotRight()
        move()
    else:
        world[robot] = if i == 0: Color.Black else: Color.White
    m.toggle = not m.toggle

proc run2o(m: var vm) = 
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
            pgm_output(m, a)
            pc += 2
            m.pc = pc
            return
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
            return
        (op, amode, bmode, cmode) = decode(m.pgm[pc])
        if trace: echo "@", pc, (op, amode, bmode, cmode), m.pgm[pc+1], ",", m.pgm[pc+2], ",", m.pgm[pc+3]
    m.halted = true


proc run(m: var vm) =
    while not m.halted:
        run2o(m)

proc readin(): seq[int] =
    var pgm: seq[int]
    for line in input:
        if line != "":
            var codes = line.split(',')
            for s in codes:
                pgm.add(parseInt(s))
    return pgm

proc part1() = 
    var m = initvm(readin())
    run(m)
    echo "Part 1: ", world.len

# part1() # 2322

proc display_world() =
    var outstr: string
    for y in miny..maxy:
        for x in minx..maxx:
            var ochar = ' '
            let key = (x,y)
            if world.hasKey(key) and world[key] == Color.White: ochar = '#'
            outstr.add(ochar)
        outstr.add('\n')
    echo(outstr)
                
proc part2() = 
    var m = initvm(readin())
    world[robot] = Color.White
    run(m)
    echo "Part 2: ", world.len
    display_world()

part2()
# not JHARGBCU, but JHARBGCU

