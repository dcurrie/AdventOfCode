import strutils, sequtils, strscans, os, sets, tables, parseutils, sugar, algorithm, deques

let
    params = commandLineParams()
    fname = if params.len > 0 : params[0] else : "input.txt"
    input = readFile(fname)

#echo("Params: ", params)

proc readPlayer(ps: string): seq[int] =
    var psl = ps.splitLines
    for i in 1..psl.len-1: # skip first line
        result.add(parseInt(psl[i]))

proc readIn(input: string): (Deque[int], Deque[int]) =
    var p1p2 = input.strip.split("\n\n")
    return (readPlayer(p1p2[0]).toDeque, readPlayer(p1p2[1]).toDeque)

# The game consists of a series of rounds with a few changes:
#
# Before either player deals a card, if there was a previous round in this game
# that had exactly the same cards in the same order in the same players' decks,
# the game instantly ends in a win for player 1. Previous rounds from other games
# are not considered. (This prevents infinite games of Recursive Combat, which everyone agrees is a bad idea.)
#
# Otherwise, this round's cards must be in a new configuration; the players begin
# the round by each drawing the top card of their deck as normal.
#
# If both players have at least as many cards remaining in their deck as the
# value of the card they just drew, the winner of the round is determined by
# playing a new game of Recursive Combat (see below).
#
# Otherwise, at least one player must not have enough cards left in their deck
# to recurse; the winner of the round is the player with the higher-value card.
#
# As in regular Combat, the winner of the round (even if they won the round by
# winning a sub-game) takes the two cards dealt at the beginning of the round
# and places them on the bottom of their own deck (again so that the winner's
# card is above the other card). Note that the winner's card might be the
# lower-valued of the two cards if they won the round due to winning a sub-game.
# If collecting cards by winning the round causes a player to have all of the
# cards, they win, and the game ends.

# Hint from reddit... (not implemented)
# Optimisation logic - During a sub game, if we see that the player 1 has the
# card with the highest number and the value of that card is more than the
# length of both decks combined, then we can declare Player 1 as winner!
# This will significantly reduce the recursion space.

var ght: Table[(string,string),(Deque[int],Deque[int])]

proc copydeq(d: Deque[int], n: int): Deque[int] =
    for i in 0..n-1:
        result.addLast(d[i])

proc game(p1in: Deque[int], p2in: Deque[int]): (Deque[int],Deque[int]) =
    var p1 = p1in
    var p2 = p2in
    var hs: HashSet[(string,string)]
    var p1ip2is = ($p1in,$p2in)
    if ght.contains((p1ip2is)):
        return (ght[p1ip2is])
    while p1.len > 0 and p2.len > 0:
        var p1p2s = ($p1,$p2)
        if hs.contains((p1p2s)):
            # return (true, p1, p2) bypasses ght
            # ensure that p1.len > p2.len
            # p1 and p2 are otherwise unused since this is not top level
            p2.clear
            break
        hs.incl(p1p2s)
        var t1 = popFirst(p1)
        var t2 = popFirst(p2)
        var p1wins = false
        if p1.len >= t1 and p2.len >= t2:
            var (p1r,p2r) = game(copydeq(p1,t1),copydeq(p2,t2))
            p1wins = p1r.len > p2r.len
        else:
            p1wins = t1 > t2
        if p1wins:
            p1.addLast(t1)
            p1.addLast(t2)
        else:
            p2.addLast(t2)
            p2.addLast(t1)
    result = (p1, p2)
    ght[p1ip2is] = result

proc score(p: var Deque[int]): int =
    var m = p.len
    while p.len > 0:
        result += m * popFirst(p)
        m -= 1

proc part2(input: string): (int,int) =
    ght.clear
    var (p1, p2) = readIn(input)
    var (p1r,p2r) = game(p1,p2)
    return(score(p1r), score(p2r))

echo part2("""Player 1:
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

echo part2(input)
