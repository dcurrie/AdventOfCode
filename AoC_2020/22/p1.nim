import strutils, sequtils, strscans, os, sets, tables, parseutils, sugar, algorithm, deques

let
    params = commandLineParams()
    fname = if params.len > 0 : params[0] else : "input.txt"
    input = readFile(fname)

#echo("Params: ", params)

# the game consists of a series of rounds: both players draw their top card,
# and the player with the higher-valued card wins the round. The winner keeps
# both cards, placing them on the bottom of their own deck so that the winner's
# card is above the other card. If this causes a player to have all of the
# cards, they win, and the game ends.

proc readPlayer(ps: string): seq[int] =
    var psl = ps.splitLines
    for i in 1..psl.len-1: # skip first line
        result.add(parseInt(psl[i]))

proc readIn(input: string): (Deque[int], Deque[int]) =
    var p1p2 = input.strip.split("\n\n")
    return (readPlayer(p1p2[0]).toDeque, readPlayer(p1p2[1]).toDeque)

proc score(p: var Deque[int]): int =
    var m = p.len
    while p.len > 0:
        result += m * popFirst(p)
        m -= 1

proc part1(input: string): (int,int) =
    var (p1, p2) = readIn(input)
    #echo(p1,p2)
    while p1.len > 0 and p2.len > 0:
        var t1 = popFirst(p1)
        var t2 = popFirst(p2)
        if t1 > t2:
            p1.addLast(t1)
            p1.addLast(t2)
        else:
            p2.addLast(t2)
            p2.addLast(t1)
        #echo(p1,p2)
    return(score(p1),score(p2))

echo part1("""Player 1:
9
2
6
3
1

Player 2:
5
8
4
7
10""")

echo part1(input)
