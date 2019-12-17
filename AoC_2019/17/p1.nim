import strutils, sequtils, strscans, os, tables, sets, algorithm, unicode

import ../../Utils/dgraph

when defined(usethewrongapproach):
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

proc part1a(m: var vm) =
    var x = 0
    var y = 0
    while not m.halted:
        checkmm(x,y)
        let t = run2o(m)
        case t:
        of 35: world[(x,y)] = Scaffold; x += 1; dbg('#')
        of 46: world[(x,y)] = Empty; x += 1; dbg('.')
        of 10: y += 1; x = 0; dbg('\n')
        of '^'.int: world[(x,y)] = Scaffold; x += 1; dbg('^'); robot = (x-1,y)
        of 'v'.int: world[(x,y)] = Scaffold; x += 1; dbg('v')
        of '<'.int: world[(x,y)] = Scaffold; x += 1; dbg('<')
        of '>'.int: world[(x,y)] = Scaffold; x += 1; dbg('>')
        else: echo "Part 1a wtf: ", t
    if x == 0: maxy = y - 1
        

proc readin(): seq[int] =
    var pgm: seq[int]
    for line in input:
        if line != "":
            var codes = line.split(',')
            for s in codes:
                pgm.add(parseInt(s))
    return pgm

var g = DGraph[Locn,int]()

proc part1(): int = 
    verbo = true
    var m = initvm(readin())
    part1a(m)
    display_world()
    # find intersections
    for y in miny..(maxy-1):
        for x in minx..(maxx-1):
            let fmkey = (x,y)
            let fmtyp = world.getOrDefault(fmkey)
            if fmtyp == Scaffold:
                let rtkey = (x,y+1)
                let rttyp = world.getOrDefault(rtkey)
                let dnkey = (x+1,y)
                let dntyp = world.getOrDefault(dnkey)
                if rttyp == Scaffold:
                    let _ = g.add_edges(@[(fmkey, rtkey, 1),(rtkey, fmkey, 1)])
                if dntyp == Scaffold:
                    let _ = g.add_edges(@[(fmkey, dnkey, 1),(dnkey, fmkey, 1)])
    for n in g.allnodes:
        if n.outdegree > 2: result += n.key.x * n.key.y

echo "Part 1, sum align params: ", part1() # 4112

proc rotLeft(direction: Locn): Locn =
    result = (direction.y, -direction.x) # (0,-1) (-1,0) ( 0,1) (1, 0)

proc rotRight(direction: Locn): Locn = 
    result = (-direction.y, direction.x) # (1, 0) ( 0,1) (-1,0) (0,-1)

proc `+`(a, b: Locn): Locn = (a.x + b.x, a.y + b.y)

proc part2(): int = 
    verbo = true

    var start: Locn = (-1,-1)
    var endnd: Locn = (-1,-1)
    for n in g.allnodes:
        if n.outdegree == 1 and n.key != robot:
            if endnd.x != -1: echo "Multiple ends!?", endnd
            endnd = n.key
        if n.indegree == 1 and n.key == robot:
            if start.x != -1: echo "Multiple starts!?", start
            start = n.key
    echo "Start, end, robot: ", start, endnd, robot
    assert start == robot
    when defined(usethewrongapproach):
        let (dist, prev) = g.dijkstra(start)
        echo "Distance of path: ", dist[endnd]
    var dir: Locn = (0,-1) # start up
    var path = @[start]
    var cmds: seq[int] = @[]
    var count = 0
    while robot != endnd:
        if world.getOrDefault(robot + dir) == Scaffold:
            robot = robot + dir
            path.add(robot)
            count += 1
        elif world.getOrDefault(robot + rotLeft(dir)) == Scaffold:
            dir = rotLeft(dir)
            if count > 0: cmds.add(count)
            cmds.add('L'.int)
            robot = robot + dir
            path.add(robot)
            count = 1
        elif world.getOrDefault(robot + rotRight(dir)) == Scaffold:
            dir = rotRight(dir)
            if count > 0: cmds.add(count)
            cmds.add('R'.int)
            robot = robot + dir
            path.add(robot)
            count = 1
        else:
            break
    if count > 0: cmds.add(count)
    if verbo:
        var qnodes = 0
        for y in miny..(maxy-1):
            for x in minx..(maxx-1):
                if world[(x,y)] == Scaffold:
                    qnodes += 1
        #echo path
        echo cmds
        echo "Nodes covered: ", toHashSet(path).len, " of ", (g.number_of_nodes, qnodes)
        echo "With ", cmds.len, " commands"

    #@[82, 10, 82, 10, 82, 6, 82, 4, 82, 10, 82, 10, 76, 4, 82, 10, 82, 10, 82, 6, 82, 4, 82, 4, 76, 4, 76, 10, 76, 10, 82, 10, 82, 10, 82, 6, 82, 4, 82, 10, 82, 10, 76, 4, 82, 4, 76, 4, 76, 10, 76, 10, 82, 10, 82, 10, 76, 4, 82, 4, 76, 4, 76, 10, 76, 10, 82, 10, 82, 10, 76, 4]
    #@['A'.int, 82, 10, 82, 10, 76, 4, 'A'.int, 82, 4, 76, 4, 76, 10, 76, 10, 'A'.int, 82, 10, 82, 10, 76, 4, 82, 4, 76, 4, 76, 10, 76, 10, 82, 10, 82, 10, 76, 4, 82, 4, 76, 4, 76, 10, 76, 10, 82, 10, 82, 10, 76, 4]
    #@['A'.int, 'B'.int, 'A'.int, 82, 4, 76, 4, 76, 10, 76, 10, 'A'.int, 'B'.int, 82, 4, 76, 4, 76, 10, 76, 10, 'B'.int, 82, 4, 76, 4, 76, 10, 76, 10, 'B'.int]
    #@['A'.int, 'B'.int, 'A'.int, 'C'.int, 'A'.int, 'B'.int, 'C'.int, 'B'.int, 'C'.int, 'B'.int]
    let a = @[82, 10, 82, 10, 82, 6, 82, 4]
    let b = @[82, 10, 82, 10, 76, 4]
    let c = @[82, 4, 76, 4, 76, 10, 76, 10]
    let p = @['A'.int, 'B'.int, 'A'.int, 'C'.int, 'A'.int, 'B'.int, 'C'.int, 'B'.int, 'C'.int, 'B'.int]

    var m = initvm(readin())
    m.pgm[0] = 2

    proc add_input(m: var vm, v: seq[int]) =
        var started = false
        for i in v:
            if started:
                m.input.add(44) # comma
            else:
                started = true
            if i >= 'A'.int:
                m.input.add(i)
            elif i < 10:
                m.input.add(i + '0'.int)
            elif i == 10:
                m.input.add('1'.int)
                m.input.add('0'.int)
            else:
                echo "add_input wtf: ", i
        m.input.add(10) # newline

    add_input(m, p)
    add_input(m, a)
    add_input(m, b)
    add_input(m, c)
    m.input.add('n'.int) # no video feed
    m.input.add(10) # newline
    if verbo:
        for i in m.input:
            stdout.write(i.char)
    reverse(m.input)
    while not m.halted:
        result = run2o(m)
        if verbo and result > 0 and result < 127:
            stdout.write(result.char)
        else:
            return result

echo "Part 2, dust accumulated: ", part2() # 578918
