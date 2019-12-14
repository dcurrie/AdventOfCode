import strutils, sequtils, strscans, os, tables, math

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "in1.txt"
    input = readFile(fname)

type
    chemical = tuple [q: int, name: string]
    reaction = tuple [r: chemical, inputs: seq[chemical]]

var
    reactions: Table[string, reaction]
    inventory: Table[string, int]

proc readin(input: string): Table[string, reaction] =
    for line in input.splitLines:
        var chem: chemical
        var inps: seq[chemical]
        for seg in line.split(','):
            var q: int
            var n: string
            if scanf(strip(seg), "$i $w => $i $w", q, n, chem.q, chem.name):
                inps.add((q,n))
                result.add(chem.name, (chem, inps))
            elif scanf(strip(seg), "$i $w", q, n):
                inps.add((q,n))

var trace = true

proc produce(n: string, q: int) =

    proc consume(n: string, q: int) =
        if trace: echo "consume ", n, " ", q
        var q1 = 0
        if inventory.hasKey(n):
            q1 = inventory[n]
        else:
            inventory[n] = 0
        if q1 < q:
            produce(n, q - q1)
        inventory[n] -= q

    if trace: echo "produce ", n, " ", q
    if n == "ORE": return
    let reaction = reactions[n]
    if not inventory.hasKey(n):
        inventory[n] = 0
    let m = (q + (reaction.r.q - 1)) div reaction.r.q
    for c in reaction.inputs:
        consume(c.name, m * c.q)
    inventory[n] += m * reaction.r.q

proc part1b() =
    inventory = initTable[string, int]()
    inventory["ORE"] = int.high
    produce("FUEL", 1)
    echo inventory
    echo "Part 1: ", int.high - inventory["ORE"]

when defined(test1):
    reactions = readin("""
10 ORE => 10 A
1 ORE => 1 B
7 A, 1 B => 1 C
7 A, 1 C => 1 D
7 A, 1 D => 1 E
7 A, 1 E => 1 FUEL""")
    part1b()
    reactions = readin("""
9 ORE => 2 A
8 ORE => 3 B
7 ORE => 5 C
3 A, 4 B => 1 AB
5 B, 7 C => 1 BC
4 C, 1 A => 1 CA
2 AB, 3 BC, 4 CA => 1 FUEL""")
    #echo reactions
    part1b()

proc part1() =
    reactions = readin(input)
    part1b()

# part1() # 301997

proc part2a(instr: string): int =
    const ore:int = parseInt("1000000000000")
    reactions = readin(instr)
    inventory = initTable[string, int]()
    inventory["ORE"] = ore
    var last = ore
    for i in 1..int.high:
        produce("FUEL", 1)
        let this = inventory["ORE"]
        if trace: echo "Step ", i, " ore: ", this, " used: ", last - this
        if this <= 0:
            return i
        else:
            last = this

trace = false
#echo "Part 2: ", part2a(input)

proc part2b(instr: string): int =
    const ore:int = parseInt("1000000000000")
    reactions = readin(instr)
    inventory = initTable[string, int]()
    inventory["ORE"] = ore
    var last = ore
    for i in 1..int.high:
        produce("FUEL", 1)
        var cycle = i
        for n, q in pairs(inventory):
            if q != 0 and n != "ORE":
                cycle = 0
                break
        if cycle != 0:
            let fullc = ore div cycle
            let remcy = ore mod cycle
            echo "Cycle: ", cycle, " full cycles: ", fullc, " rem: ", remcy
            let fuelpercycle = ore - inventory["ORE"]
            var fuel = fullc * fuelpercycle
            echo "Fuel per cycle: ", fuelpercycle, " per full cycles: ", fuel
            inventory["ORE"] = ore - fuel
            for j in 1..int.high:
                produce("FUEL", 1)
                if inventory["ORE"] < 0:
                    return fuel
                if inventory["ORE"] == 0:
                    return fuel + 1
                else:
                    fuel += 1

#echo "Part 2: ", part2b(input)

proc part2c(instr: string): float =
    const ore:int = parseInt("1000000000000")
    const eps = 0.0000000000001
    reactions = readin(instr)
    inventory = initTable[string, int]()
    inventory["ORE"] = ore
    var opf:float = 0.1 # 301997.0
    var ck1 = true
    var ck2 = true
    for i in 1..int.high:
        produce("FUEL", 1)
        let opfnew = (ore - inventory["ORE"]) / i
        if abs(opfnew - opf) < eps:
            echo "Ore per unit of fuel: ", opfnew, " ", i
            echo "Fuel possible: ", ore.float / opfnew
            return ore.float / opfnew
        elif ck1 and abs(opfnew - opf) < (eps * 1000000):
            echo "Ore per unit of fuel, maybe baby: ", opfnew
            echo "Fuel possible, maybe baby: ", ore.float / opfnew
            ck1 = false
        elif ck2 and abs(opfnew - opf) < (eps * 1000):
            echo "Ore per unit of fuel, maybe: ", opfnew
            echo "Fuel possible, maybe: ", ore.float / opfnew
            ck2 = false
        opf = opfnew

# echo "Part 2: ", part2c(input) # 4459835 too low; 6216475 too low; 6216584 wrong

proc part2d(instr: string): int =
    const ore:int = parseInt("1000000000000")
    reactions = readin(instr)
    var flo = 6216475
    var fhi = 6220000
    while (flo + 1) < fhi:
        inventory = initTable[string, int]()
        inventory["ORE"] = ore
        let ftry = (flo + fhi) div 2
        produce("FUEL", ftry)
        let rore = inventory["ORE"]
        if rore == 0:
            return
        if rore < 0:
            fhi = ftry
            echo "Hi: ", fhi
        else:
            flo = ftry
            echo "Lo: ", flo
    result = flo

echo "Part 2: ", part2d(input) # 6216589

