
import strutils, sequtils, strscans, os, sets, tables, parseutils

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "input01.txt"
    input = readFile(fname)

#echo("Params: ", params)

type
  Bag   = Table[string, int]
  Bags  = Table[string, Bag]

proc readbags(input: string): Bags =
    for b in input.splitLines:
        var bag  : Bag
        var bi = b.split(':')
        if bi.len > 1:
            for bs in bi[1].split(','):
                if bs != "":
                    var bss = bs.strip
                    var qb: int
                    var ss = parseInt(bss, qb)
                    var bn = bss.substr(ss+1)
                    bag[bn] = qb
        if b != "":
            result[bi[0]] = bag

proc canhold(bags: Bags, bag: Bag, inner: string): bool =
    if bag.contains(inner):
        return true
    for ib in keys(bag):
        if canhold(bags, bags[ib], inner):
            return true
    return false


proc part1(input: string): int =
    var bags = readbags(input)
    #result = bags.len
    const inner = "shiny gold"
    for bn,bg in pairs(bags):
        if bn != inner and canhold(bags, bg, inner):
            result += 1

echo("Part 1: ", part1(input))
