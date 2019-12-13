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

type 
    Tile = enum Empty, Wall, Block, HPaddle, Ball
    Locn = tuple [x: int, y: int]

var robot: Locn
var direction: Locn = (0,-1)

var minx: int
var miny: int
var maxx: int
var maxy: int

proc checkmm() = 
    minx = min(minx, robot.x)
    maxx = max(maxx, robot.x)
    miny = min(miny, robot.y)
    maxy = max(maxy, robot.y)

var world = initTable[Locn, Tile]()

var score = 0
var qblocks = 0
var joyst = 0
var ballp: Locn
var padlp: Locn

proc pgm_input(m: var vm): int = 
    joyst =  if (ballp.x < padlp.x): -1 elif (ballp.x > padlp.x): 1 else: 0
    result = joyst

proc nop() = discard

proc place(t: Tile) = discard

proc paddle(t: Tile) = 
    if t == HPaddle: padlp = robot
    else: discard

proc destroy() =
    qblocks -= 1
    if qblocks <= 0:
        echo "No blocks left, score: ", score

proc ball(t: Tile) = 
    ballp = robot
    if t == Block: destroy()

proc wtf(t1: Tile, t2: Tile) = echo "wtf ", t1, " to ", t2

template tc(t1, t2: Tile): int = 
    (ord(t1) * (ord(Tile.high) + 1)) + ord(t2)

proc pgm_output(m: var vm, i: int) =
    case m.toggle mod 3
    of 0: robot.x = i
    of 1: robot.y = i
    else:
        if robot.x == -1 and robot.y == 0:
            score = i
        else:
            let tt = cast[Tile](i)
            let tp = if world.hasKey(robot): world[robot] else: Empty
            checkmm()
            case tc(tp, tt)
            of tc(Empty  , Empty):   nop()
            of tc(Block  , Block):   nop()
            of tc(Wall   , Wall):    nop()
            of tc(HPaddle, HPaddle): nop()
            of tc(Ball   , Ball):    nop()

            of tc(Empty  , Wall):    place(tt)
            of tc(Empty  , Block):   place(tt)

            of tc(Empty  , HPaddle): paddle(tt)
            of tc(HPaddle, Empty):   paddle(tt)

            of tc(Empty  , Ball):    ball(Empty)
            of tc(Block  , Ball):    ball(Block)
            of tc(Block  , Empty):   destroy()

            of tc(Wall   , Empty):   wtf(tp, tt)
            of tc(Wall   , Block):   wtf(tp, tt)
            of tc(Wall   , HPaddle): wtf(tp, tt)
            of tc(Wall   , Ball):    wtf(tp, tt)
            of tc(Block  , Wall):    wtf(tp, tt)
            of tc(Block  , HPaddle): wtf(tp, tt)
            of tc(HPaddle, Wall):    wtf(tp, tt)
            of tc(HPaddle, Block):   wtf(tp, tt)
            of tc(HPaddle, Ball):    wtf(tp, tt)

            of tc(Ball   , Empty):   discard
            of tc(Ball   , Wall):    wtf(tp, tt)
            of tc(Ball   , Block):   wtf(tp, tt)
            of tc(Ball   , HPaddle): wtf(tp, tt)

            else: wtf(tp, tt)

            world[robot] = tt
    m.toggle += 1

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
    for v in world.values:
        if v == Block:
            qblocks += 1
    echo "Part 1: objects: ", world.len, " blocks: ", qblocks

part1()

proc display_world() =
    var outstr: string
    for y in miny..maxy:
        for x in minx..maxx:
            var ochar = ' '
            let key = (x,y)
            if world.hasKey(key):
                ochar = case world[key]
                        of Empty: ' '
                        of Wall: '#'
                        of Block: 'X'
                        of HPaddle: '-'
                        of Ball: 'o'
            outstr.add(ochar)
        outstr.add('\n')
    echo(outstr)

proc part2() = 
    #var m = initvm(readin())
    #run(m)
    #display_world()
    # requries part1() to set qblocks
    var m = initvm(readin())
    m.pgm[0] = 2 # free play
    run(m)
    display_world()
    echo "Part 2: score: ", score

part2() # not 14444 !? oh 14538
