import strutils, sequtils, strscans, os, sets, tables, parseutils, sugar

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "input.txt"
    input = readFile(fname)

#echo("Params: ", params)


# All decisions are based on the number of occupied seats adjacent to a given
# seat (one of the eight positions immediately up, down, left, right, or diagonal
# from the seat). The following rules are applied to every seat simultaneously:
#
# If a seat is empty (L) and there are no occupied seats adjacent to it, the seat becomes occupied.
# If a seat is occupied (#) and four or more seats adjacent to it are also occupied, the seat becomes empty.
# Otherwise, the seat's state does not change.
#
# Floor (.) never changes; seats don't move, and nobody sits on the floor.

# Part 1
# Simulate your seating area by applying the seating rules repeatedly until no
# seats change state. How many seats end up occupied?

# Part 2
# Now, instead of considering just the eight immediately adjacent seats,
# consider the first seat in each of those eight directions.
#
# it now takes five or more visible occupied seats for an occupied seat to
# become empty (rather than four or more from the previous rules).
# The other rules still apply.

type
    Cell = enum Empty, Occupied, Floor

proc readIn(input: string): seq[seq[Cell]] =
    var inlayout = input.strip.splitLines
    proc charToCell(c: char): Cell =
        return case c:
            of '#': Occupied
            of 'L': Empty
            of '.': Floor
            else: echo("wtf ", c); Empty
    result.add(@[Empty] & inlayout[0].map(a => Empty) & @[Empty])
    for line in inlayout:
        result.add((@[Empty] & line.map(charToCell) & @[Empty]))
    result.add(@[Empty] & inlayout[0].map(a => Empty) & @[Empty])

proc ifOcc(c: Cell): int = return if c == Occupied: 1 else: 0

proc step(layout: var seq[seq[Cell]]): bool =
    result = true # asssume unchanged
    var prevstep = layout
    proc countDirection(d: (int, int), x: int, y: int): int =
        var (dx, dy)= d
        if prevstep[y+dy][x+dx] == Occupied:
            return 1
        if prevstep[y+dy][x+dx] == Empty:
            return 0
        return countDirection((dx, dy), x+dx, y+dy)
    var dirs = @[(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)]
    proc countOccupied(x: int, y: int): int =
        result = dirs.mapIt(countDirection(it, x, y)).foldl(a+b)
    for y in 1..layout.len-2:
        for x in 1..layout[0].len-2:
            var cnt = countOccupied(x,y)
            # If a seat is empty (L) and there are no occupied seats adjacent to it, the seat becomes occupied.
            # If a seat is occupied (#) and four or more seats adjacent to it are also occupied, the seat becomes empty.
            # Otherwise, the seat's state does not change.
            if prevstep[y][x] == Empty and cnt == 0:
                layout[y][x] = Occupied
                result = false
            elif prevstep[y][x] == Occupied and cnt >= 5:
                layout[y][x] = Empty
                result = false
            else:
                discard

proc part2(input: string): int =
    var layout = readIn(input)
    var fixpoint = false
    while not fixpoint:
        fixpoint = step(layout)
    for y in 1..layout.len-2:
        for x in 1..layout[0].len-2:
            result += layout[y][x].ifOcc

echo("Part 2: ", part2(input))
