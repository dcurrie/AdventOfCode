import strutils, sequtils, strscans, os, tables, sets, algorithm, unicode, deques

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
    input: Deque[int]
    output: seq[int]

proc initvm(input: seq[int]): vm =
    result = vm(pgm: input,
                pc: 0,
                base: 0,
                halted: false,
                toggle: 0,
                input: initDeque[int](256),
                output: @[])

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
    Tile = enum Unknown, Empty, Item, Door # 
    Locn = tuple [x: int, y: int]

var droid: Locn

var world = initTable[Locn, Tile]()

var minx: int
var miny: int
var maxx: int
var maxy: int

proc checkmm(x = droid.x, y = droid.y) = 
    minx = min(minx, x)
    maxx = max(maxx, x)
    miny = min(miny, y)
    maxy = max(maxy, y)

proc display_world() =
    echo "World ", (minx, maxx), (miny, maxy), " driod: ", droid
    var outstr: string
    for y in miny..maxy:
        for x in minx..maxx:
            var ochar:Rune = "░".runeAt(0)
            let key = (x,y)
            #if key == droid:
            #    ochar = "R".runeAt(0)
            #el
            if world.hasKey(key):
                ochar = case world[key]
                        of Empty: " ".runeAt(0)
                        of Unknown: "░".runeAt(0)
                        of Door: "█".runeAt(0)
                        of Item: "O".runeAt(0)
            outstr.add(ochar)
        outstr.add("\n ".runeAt(0))
    echo(outstr)

proc pgm_input(m: var vm): int = 
    return m.input.popFirst

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
        m.input.addLast(c.int)
    m.input.addLast('\n'.int)

proc goWest(m: var vm) =
    add_input(m, "west")

let commands = [ # Hull Breach; north, south, west
    "north", # Hallway optimized for something; Nx, Sr, Wx
    "south", # Hull Breach; north, south, Wx
    "west",  # Holodeck; mouse
    "take mouse",
    "north", # Science Lab
#   "take photons", #It is suddenly completely dark! You are eaten by a Grue!
    "south",
    "west",  # Passages
#   "take infinite loop", # You take the infinite loop. ...
    "west",  # Stables
#   "take escape pod", # You're launched into space! Bye!
    "east",
    "south", # Observatory
    "take dark matter",
    "north",
    "east",
    "north",
    "east",
    "take klein bottle",
    "west",
    "south",
    "east",  # Hull Breach; Nx, south, west
    "inv",   # mouse, klein bottle, dark matter
    "north", # Hallway optimized for something; Nx, Sr, Wx
#   "north", # The boxes just contain more boxes.  Recursively
#   "north", # You can't go that way
    "west",  # Sick Bay: Supports both Red-Nosed Reindeer medicine and regular reindeer medicine; - east, Sx
#   "west",  # You can't go that way
    "south", # Kitchen; Everything's freeze-dried; - Nr, Ex, Wx
    "take planetoid",
#   "north",
#   "east",
#   "south", 
#   "drop planetoid",
#   "north",
#   "south",
    "east",  # Navigation; Status: Stranded. Please supply measurements from fifty stars to recalibrate. Ex, south, west
    "take mutex",
    "east",  # Gift Wrapping Center; west
#   "east",
#   "north",
    "west",  # Navigation;
    "south", # Hot Chocolate Fountain; Nr, Sx Wx
    "take whirled peas",
#   "north", # Navigation;
    "south", # Corridor The metal walls and the metal floor are slightly different colors. Or are they?; Nr, Ex
#   "take giant electromagnet",
#   "east",  # The giant electromagnet is stuck to you.  You can't move!!
#   "south",
    "east",  # Security Checkpoint In the next room, a pressure-sensitive floor will verify your identity. N?, Wr
    "inv",
#   "north", # Pressure-Sensitive Floor: A loud, robotic voice says "Alert! Droids on this ship are lighter than the detected value!" and you are ejected back to the checkpoint.
    "west",  # Corridor w/electromagnet
    "north", # Hot Chocolate Fountain
    "west",  # Crew Quarters
#   "take molten lava", The molten lava is way too hot! You melt!
    "east",  # Hot Chocolate Fountain; 
    "north", # Navigation; 
    "west",  # Kitchen
    "west",  # Warp Drive Maintenance, Er
    "take antenna",
    "east",  # Kitchen
    "north", # Sick Bay
    "inv",   # whirled peas, planetoid, mouse, mutex, antenna
    "east",  # Hallway
    "south", # Hull Breach
#   "drop mouse" # tried them all
    "south", # Engineering You see a whiteboard with plans for Springdroid v2.
    "take fuel cell",
    "north", # Hull Breach
    "north", # Hallway
    "west",  # Sick Bay
    "south", # Kitchen
    "east",
    "south",
    "south",
    "east",
    "inv",   # whirled peas, planetoid, mouse, klein bottle, mutex, dark matter, antenna, fuel cell
    "north", # fail
#   "drop whirled peas",
#   "drop planetoid",
#   "drop mouse",
#   "drop klein bottle",
#   "drop mutex",
#   "drop dark matter",
#   "drop antenna",
#   "drop fuel cell",
#   "north", # fail
    ]

var items = ["antenna", "dark matter", "fuel cell", "klein bottle", "mouse", "mutex", "planetoid", "whirled peas"]

iterator itemscomb(): string = 
    while true:
        for i in 1..7:
            for j in 0..i:
                yield "drop " & items[j]
            yield "inv"
            yield "north"
            for j in 0..i:
                yield "take " & items[j]
        if not items.nextPermutation():
            break

proc part1(): int = 
    verbo = true
    var m = initvm(readin())
    var n = 0
    var line = ""
    while not m.halted and n < commands.len:
        let t = run2o(m)
        if t < 128:
            stdout.write(t.char)
            if t == '\n'.int:
                line = ""
            elif t == '?'.int and line == "Command":
                add_input(m, commands[n])
                inc n
            else:
                line &= t.char
        else:
            return t
    for item in itemscomb():
        if m.halted: break
        while true:
            if m.halted: break
            let t = run2o(m)
            if t < 128:
                stdout.write(t.char)
                if t == '\n'.int:
                    line = ""
                elif t == '?'.int and line == "Command":
                    add_input(m, item)
                    break
                else:
                    line &= t.char
            else:
                return t


echo "Part 1: ", part1() # 


#[
Items in your inventory:
- planetoid
- mutex
- antenna
- fuel cell

Command?north




== Pressure-Sensitive Floor ==
Analyzing...

Doors here lead:
- south

A loud, robotic voice says "Analysis complete! You may proceed." and you enter the cockpit.
Santa notices your small droid, looks puzzled for a moment, realizes what has happened, and radios your ship directly.
"Oh, hello! You should be able to get in by typing 16810049 on the keypad at the main airlock."
]#