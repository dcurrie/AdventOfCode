import strutils, sequtils, strscans, os

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "in1.txt"
    input = readFile(fname)

#echo("Params: ", params)


# https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/

type Point = tuple[x: int, y: int]

# Given three colinear points p, q, r, the function checks if 
# point q lies on line segment 'pr' 
proc onSegment(p: Point, q: Point, r: Point): bool =
    result = false
    if (q.x <= max(p.x, r.x) and q.x >= min(p.x, r.x) and q.y <= max(p.y, r.y) and q.y >= min(p.y, r.y)):
        return true

# To find orientation of ordered triplet (p, q, r). 
# The function returns following values 
# 0 --> p, q and r are colinear 
# 1 --> Clockwise 
# 2 --> Counterclockwise 
proc orientation(p: Point, q: Point, r: Point): int = 
    # See https://www.geeksforgeeks.org/orientation-3-ordered-points/ 
    # for details of below formula. 
    let val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y); 
  
    if  (val == 0): result = 0 # colinear 
    elif (val > 0): result = 1 # clockwise
    else:           result = 2 # counterclockwise

proc readIn(input: string): seq[Point] =
    var y = 0
    for line in input.splitLines:
        if line != "":
            for x in 0..(line.len - 1):
                if line[x] == '#': result.add((x,y))
            y += 1

proc detects(c: Point, w: seq[Point]): int =
    for p in w:
        if p != c:
            var good = 1
            for o in w:
                if p == o or c == o:
                    continue
                if orientation(c, o, p) == 0 and onSegment(c, o, p):
                    good = 0
                    break
            result += good

proc part1(w: seq[Point]) = 
    var cnts: seq[int]
    cnts = w.mapIt(detects(it, w))
    var m = cnts.max
    for i, x in cnts:
        #echo x, " ", w[i]
        if cnts[i] == m: echo m, " ", w[i]

when defined(test1):
    var txt = ".#..#\n.....\n#####\n....#\n...##\n"
    var pts = readIn(txt)
    #echo pts
    part1(pts)

part1(readIn(input))
