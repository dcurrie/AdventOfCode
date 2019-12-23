import strutils, sequtils, strscans, os, tables, sets, algorithm, unicode
#import deques

# compile with the --threads:on command line switch.

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
    uid: int
    input: seq[int]
    #input: Deque[int]
    #output: seq[int]

var nicchans: array[0..49, Channel[(int,int)]]

proc initvm(input: seq[int]): vm =
    result = vm(pgm: input,
                pc: 0,
                base: 0,
                halted: false,
                toggle: 0,
                input: @[]
                #input: Deque[int](),
                #output: @[]
                )

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

# To receive a packet from another computer, the NIC will use an input instruction.
# If the incoming packet queue is empty, provide -1. Otherwise, provide the X value
# of the next packet; the computer will then use a second input instruction to receive
# the Y value for the same packet. Once both values of the packet are read in this way,
# the packet is removed from the queue.

proc pgm_input(m: var vm): int = 
    if m.input.len > 0:
        return m.input.pop
    let (ok, v) = tryRecv(nicchans[m.uid])
    if ok:
        if verbo: echo "Receiving @", m.uid, " ", v
        let (x, y) = v
        m.input.add(y)
        return x
    else:
        return -1

proc add_input(m: var vm, x, y: int) =
    #m.input.addLast(x)
    #m.input.addLast(y)
    discard

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

proc readin(input: seq[string]): seq[int] =
    var pgm: seq[int]
    for line in input:
        if line != "":
            var codes = line.split(',')
            for s in codes:
                pgm.add(parseInt(s))
    return pgm

# To send a packet to another computer, the NIC will use three output instructions that provide
# the destination address of the packet followed by its X and Y values. For example, three output
# instructions that provide the values 10, 20, 30 would send a packet with X=20 and Y=30 to the
# computer with address 10.

proc nic(npgm: tuple[n: int, src: seq[string]]) {.thread.} =
    let (n, src) = npgm
    var m = initvm(readin(src))
    m.uid = n
    m.input.add(n)
    if verbo: echo "Starting # ", n
    while not m.halted:
        let t = run2o(m)
        if t <= 49:
            let x = run2o(m)
            let y = run2o(m)
            send(nicchans[t], (x, y))
            if verbo: echo "Send ", n, "->", t, " ", (x,y)
        elif t == 255:
            let x = run2o(m)
            let y = run2o(m)
            echo "Part 1: ", y, (t, x, y)
        else:
            echo "Wtf @", n, " got: ", t
    if verbo: echo "Terminating # ", n

proc part1() = 
    verbo = true
    #let pgm = readin(input)
    for i in 0..49:
        nicchans[i] = Channel[(int,int)]()
        open(nicchans[i], 0)
        #send(nicchans[i], i)
    var thr: array[0..49, Thread[tuple[n: int, src: seq[string]]]]
    for i in 0..49:
        createThread(thr[i], nic, (i, input))
    joinThreads(thr)


part1() # 

