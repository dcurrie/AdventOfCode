import strutils, sequtils, strscans, os, tables, sets, algorithm, unicode

import ../../Utils/dgraph

when defined(usethewrongapproach):
    import ../../Utils/dijkstra
    import ../../Utils/daryheap

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "in1.txt"
    input = readFile(fname).splitLines

var trace = false
var verbo = false

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

proc pgm_input(m: var vm): int = 
    let i = m.input.pop
    #if verbo: echo "in: ", i
    return i

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

proc readin(): seq[int] =
    var pgm: seq[int]
    for line in input:
        if line != "":
            var codes = line.split(',')
            for s in codes:
                pgm.add(parseInt(s))
    return pgm

# ################################################################################

type 
    Tile = enum Unknown, Empty, Pulled # 
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
                        of Pulled: "█".runeAt(0)
            outstr.add(ochar)
        outstr.add("\n ".runeAt(0))
    echo(outstr)

#proc dbg(c: char) =
#    if verbo:
#        stdout.write(c)

proc part1(m: var vm): int =
    verbo = true
    for x in 0..49:
        for y in 0..49:
            if m.halted:
                if verbo: echo "Halted!"
                break
            var m2 = m
            m2.input.add(y) # add in reverse order since it's a stack
            m2.input.add(x)
            let t = run2o(m2)
            case t:
            of 0: world[(x,y)] = Empty # ; dbg('.')
            of 1: world[(x,y)] = Pulled; result += 1 # ; dbg('#')
            else: echo "Part 1 wtf: ", t
        
var m = initvm(readin())
echo "Part 1, points affected: ", part1(m) # 173


proc part2(m: var vm): int =
    verbo = true
    #minx = 0
    #miny = 0
    #maxx = 50
    #maxy = 50
    #display_world()
    let y1 = 500
    let y3 = 1000
    var x1, x2: int
    # look at row 200
    var state = 0
    for x in 0..1000:
        var m2 = m
        m2.input.add(y1) # y
        m2.input.add(x)
        let t = run2o(m2)
        case (state + t):
        of 0: state = 2
        of 1: echo "Error, got point in state 0: ", x, " ", t; break
        of 2: discard # waiting
        of 3: x1 = x; state = 4 # transition 1
        of 4: x2 = x; break # done
        of 5: discard # waiting
        else: echo "Part 2a wtf: ", t
    var x3, x4: int
    # look at row 400
    state = 0
    for x in 0..2000:
        var m2 = m
        m2.input.add(y3) # y
        m2.input.add(x)
        let t = run2o(m2)
        case (state + t):
        of 0: state = 2
        of 1: echo "Error, got point in state 0"; break
        of 2: discard # waiting
        of 3: x3 = x; state = 4 # transition 1
        of 4: x4 = x; break # done
        of 5: discard # waiting
        else: echo "Part 2b wtf: ", t
    echo "Width of ", x2 - x1, " at ", y1
    echo "Width of ", x4 - x3, " at ", y3
    echo "Predict y for row of 100: ", (100 * y3) / (x4 - x3)
    #result = [(x1,y1),(x2,y1),(x3,y3),(x4,y3)]
    # we are looking for two rows where
    #  minx(row2) == maxx(row2 - 99) - 99
    #  and the row (row2 - 99) is at least 100 wide
    var maxx = Table[int,int]() # row to maxx
    for y in 750..1500:
        state = 0
        for x in 500..1500:
            var m2 = m
            m2.input.add(y)
            m2.input.add(x)
            let t = run2o(m2)
            case (state + t):
            of 0: state = 2
            of 1: echo "Error, got point in state 0"; break
            of 2: discard # waiting
            of 3: # first point
                x3 = x;
                if maxx.hasKey(y-99):
                    if (maxx[y-99] - 99) == x3:
                        echo "Found! ", (x3, y)
                        return (x3 * 10000) + (y-99)
                state = 4 # transition 1
            of 4: # last point + 1
                x4 = x - 1; 
                if (x - x3) >= 100:
                    maxx[y] = x4
                break # done this row
            of 5: discard # waiting
            else: echo "Part 2 wtf: ", t

            
echo "Part 2, beam: ", part2(m) # 6671097
