import strutils, sequtils, strscans, os, tables, sets, algorithm, unicode

when defined(usethewrongapproach):
    import ../../Utils/dgraph
    import ../../Utils/dijkstra
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

#proc resetvm(m: var vm) =
#    m.pc = 0
#    m.base = 0
#    m.halted = false
#    m.toggle = 0
#    #m.input = @[]  # ??
#    m.output = @[]

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
    Tile = enum Unknown, Empty, Scaffold # , Up, Right, Left, Down, Falling
    Locn = tuple [x: int, y: int]

var robot: Locn

var world = initTable[Locn, Tile]()

var minx: int
var miny: int
var maxx: int
var maxy: int

proc checkmm(x = robot.x, y = robot.y) = 
    minx = min(minx, x)
    maxx = max(maxx, x)
    miny = min(miny, y)
    maxy = max(maxy, y)

proc display_world() =
    echo "World ", (minx, maxx), (miny, maxy), " driod: ", robot
    var outstr: string
    for y in miny..maxy:
        for x in minx..maxx:
            var ochar:Rune = "░".runeAt(0)
            let key = (x,y)
            #if key == robot:
            #    ochar = "R".runeAt(0)
            #el
            if world.hasKey(key):
                ochar = case world[key]
                        of Empty: " ".runeAt(0)
                        of Unknown: "░".runeAt(0)
                        of Scaffold: "█".runeAt(0)
                        # of Oxygen: "O".runeAt(0)
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

proc dbg(c: char) =
    if verbo:
        stdout.write(c)

proc readin(): seq[int] =
    var pgm: seq[int]
    for line in input:
        if line != "":
            var codes = line.split(',')
            for s in codes:
                pgm.add(parseInt(s))
    return pgm

proc add_input(m: var vm, s: string) =
    echo s
    for c in s:
        m.input.add(c.int)
    m.input.add('\n'.int)

proc part1(): int = 
    verbo = true
    var m = initvm(readin())
    add_input(m, "NOT C J")
    add_input(m, "AND D J")
    add_input(m, "NOT A T")
    add_input(m, "OR T J")
    add_input(m, "WALK")
    reverse(m.input)
    while not m.halted:
        let t = run2o(m)
        if t < 128:
            stdout.write(t.char)
        else:
            return t

echo "Part 1, damage: ", part1() # 19355862

proc part2(): int = 
    verbo = true
    var m = initvm(readin())
    add_input(m, "OR E J")
    add_input(m, "OR H J")
    add_input(m, "AND D J")
    add_input(m, "OR A T") 
    add_input(m, "AND B T")
    add_input(m, "AND C T")
    add_input(m, "NOT T T")
    add_input(m, "AND T J")
    add_input(m, "RUN")
    reverse(m.input)
    while not m.halted:
        let t = run2o(m)
        if t < 128 and t > 0:
            stdout.write(t.char)
        else:
            return t

echo "Part 1, damage: ", part2() # 1140470745
