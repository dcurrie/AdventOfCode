import strutils, sequtils, strscans, os, math, algorithm

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "in1.txt"
    input = readFile(fname)

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

proc detects(c: Point, w: seq[Point]): seq[Point] =
    for p in w:
        if p != c:
            var good = true
            for o in w:
                if p == o or c == o:
                    continue
                if orientation(c, o, p) == 0 and onSegment(c, o, p):
                    good = false
                    break
            if good: result.add(p)

var station: Point

proc cmpPts(a, b: Point): int =
    let aa = TAU - arctan2(float64(a.x - station.x), float64(a.y - station.y))
    let ba = TAU - arctan2(float64(b.x - station.x), float64(b.y - station.y))
    result = if aa < ba: -1 else: 1

proc part2(w: var seq[Point]) = 
    var cnts: seq[int]
    var vizs: seq[seq[Point]]
    vizs = w.mapIt(detects(it, w))
    cnts = vizs.mapIt(it.len)
    var m = cnts.max
    var c: Point
    var viz: seq[Point]
    for i, x in cnts:
        if cnts[i] == m:
            echo m, " ", w[i]
            c = w[i]
            station = w[i]
            viz = vizs[i]
    var nth = 1
    while viz.len > 0:
        viz.sort(cmpPts)
        for p in viz:
            echo "The ", nth, " asteroid to be vaporized is at ", p
            nth += 1
            w.keepItIf(it != p)
        viz = detects(c, w)

# Embarrassed that I had to figure out rotation of coordinates by trial and error...
#
#    echo w
#    for p in w:
#        #echo p, TAU - arctan2(float64(c.y - p.y), float64(p.x - c.x))
#        #echo p, TAU - arctan2(float64(c.x - p.x), float64(c.y - p.y))
#        #echo p, TAU - arctan2(float64(p.y - c.y), float64(c.x - p.x))
#        echo p, TAU - arctan2(float64(p.x - c.x), float64(p.y - c.y))

when defined(test2):
    var txt = ".#....#####...#..\n##...##.#####..##\n##...#...#.#####.\n..#.....#...###..\n..#.#.....#....##\n"
    var pts = readIn(txt)
    part2(pts)

var w = readIn(input)
part2(w)
