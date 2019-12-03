
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
  
# The main function that returns true if line segment 'p1q1' 
# and 'p2q2' intersect. 
proc doIntersect(p1: Point, q1: Point, p2: Point, q2: Point): (bool, Point) =
    # Find the four orientations needed for general and 
    # special cases 
    let
        o1 = orientation(p1, q1, p2)
        o2 = orientation(p1, q1, q2)
        o3 = orientation(p2, q2, p1)
        o4 = orientation(p2, q2, q1)
    # General case 
    if (o1 != o2 and o3 != o4):
        return (true, (-3, -3))
    # Special Cases 
    # p1, q1 and p2 are colinear and p2 lies on segment p1q1 
    if (o1 == 0 and onSegment(p1, p2, q1)): return (true, p2)
    # p1, q1 and q2 are colinear and q2 lies on segment p1q1 
    if (o2 == 0 and onSegment(p1, q2, q1)): return (true, q2)
    # p2, q2 and p1 are colinear and p1 lies on segment p2q2 
    if (o3 == 0 and onSegment(p2, p1, q2)): return (true, p1)
    # p2, q2 and q1 are colinear and q1 lies on segment p2q2 
    if (o4 == 0 and onSegment(p2, q1, q2)): return (true, q1)
    #
    return (false, (-2, -2)); # Doesn't fall in any of the above cases 


when defined(test0):
    block:
        let p1: Point = (1, 1)
        let q1: Point = (10, 1)
        let p2: Point = (1, 2)
        let q2: Point = (10, 2)

        let (b, _) = doIntersect(p1, q1, p2, q2)
        if b:
            echo("Yes")
        else:
            echo("No")
    block:
        let p1: Point = (10, 1)
        let q1: Point = (0, 10)
        let p2: Point = (0, 0)
        let q2: Point = (10, 10)
        let (b, _) = doIntersect(p1, q1, p2, q2)
        if b:
            echo("Yes")
        else:
            echo("No")
    block:
        let p1: Point = (-5, -5)
        let q1: Point = (0, 0)
        let p2: Point = (1, 1)
        let q2: Point = (10, 10)
        let (b, _) = doIntersect(p1, q1, p2, q2)
        if b:
            echo("Yes")
        else:
            echo("No")
    # expect: No Yes No

proc in2pts(input: string): seq[seq[Point]] =
    #var path: seq[seq[Point]]
    var pnum = 0
    for line in input.splitLines:
        if line != "":
            result.add(@[])
            var steps = line.split(',')
            var x = 0
            var y = 0
            result[pnum].add((x,y))
            for s in steps:
                if s[0] == 'U':
                    y += parseInt(substr(s,1))
                    result[pnum].add((x,y))
                elif s[0] == 'D':
                    y -= parseInt(substr(s,1))
                    result[pnum].add((x,y))
                elif s[0] == 'L':
                    x -= parseInt(substr(s,1))
                    result[pnum].add((x,y))
                elif s[0] == 'R':
                    x += parseInt(substr(s,1))
                    result[pnum].add((x,y))
            pnum += 1

# proc ptintersect0(p1: Point, q1: Point, p2: Point, q2: Point): Point =
#     # can be simplified since lines are always horizontal or vertical
#     # common denominator
#     let di = ((p1.x - p2.x) * (q1.y - q2.y)) - ((p1.y - p2.y) * (q1.x - q2.x))
#     if di == 0:
#         # lines are colinear
#         # punt?
#         result = (-1, -1)
#     else:
#         # x and y numerators
#         let xn = (((p1.x * p2.y) - (p1.y * p2.x)) * (q1.x - q2.x)) -
#                  ((p1.x - p2.x) * ((q1.x * q2.y) - (q1.y * q2.x)))
#         let yn = (((p1.x * p2.y) - (p1.y * p2.x)) * (q1.y - q2.y)) -
#                  ((p1.y - p2.y) * ((q1.x * q2.y) - (q1.y * q2.x)))
#         result = (xn /% di, yn /% di)

proc ptintersect(p1: Point, q1: Point, p2: Point, q2: Point): Point =
    if p1.x == q1.x:
        # line p is vertical
        if p2.y == q2.y:
            # line q is horizontal
            result = (p1.x, q2.y)
        else:
            # ugh
            echo("Ugh 4 ", p1, q1, p2, q2)
            result = (-4, -4)
    elif p2.x == q2.x:
        # line q is vertical
        if p1.y == q1.y:
            # line p is horizontal
            result = (p2.x, q1.y)
        else:
            # ugh
            result = (-5, -5)
    else:
        # ugh
        result = (-6, -6)

iterator ppairs(pts: seq[Point]): (Point, Point) = # tuple[
    for i in 0..pts.len-2:
        yield (pts[i], pts[i+1])

proc intersects(pts: seq[seq[Point]]): seq[Point] =
    for p1, q1 in ppairs(pts[0]):
        for p2, q2 in ppairs(pts[1]):
            let (b, x) = doIntersect(p1, q1, p2, q2)
            if b:
                if x.x < 0:
                    let x = ptintersect(p1, q1, p2, q2)
                    if x.x != 0 or x.y != 0:
                        result.add(x)
                elif x.x == 0 and x.y == 0:
                    discard 
                else:
                    result.add(x)

proc minintersect(pts: seq[Point]): int =
    result = 0
    for p in pts:
        let md = abs(p.x) + abs(p.y)
        if md > 0 and (result == 0 or md < result):
            result = md

when defined(test1):
    #echo(in2pts("R75,D30,R83,U83,L12,D49,R71,U7,L72\nU62,R66,U55,R34,D71,R55,D58,R83"))
    var pts = in2pts("R8,U5,L5,D3\nU7,R6,D4,L4")
    #echo(pts, "\n", intersects(pts))
    echo("1   6?: ", minintersect(intersects(pts)))
    pts = in2pts("R75,D30,R83,U83,L12,D49,R71,U7,L72\nU62,R66,U55,R34,D71,R55,D58,R83")
    echo("2 159?: ", minintersect(intersects(pts)))
    pts = in2pts("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51\nU98,R91,D20,R16,D67,R40,U7,R15,U6,R7")
    echo("2 135?: ", minintersect(intersects(pts)))

echo("Part 1: ", minintersect(intersects(in2pts(input))))

proc distto(p, q: Point): int =
    if p.x == q.x:
        result = abs(p.y - q.y)
    else:
        result = abs(p.x - q.x)

proc shorttr(pts: seq[Point], ints: seq[Point]): seq[int] = 
    var dist = 0
    result = map(ints, proc (x: Point): int = 0)
    #echo("path ", pts)
    for p1, q1 in ppairs(pts):
        for zi in 0..<ints.len:
            let z = ints[zi]
            if orientation(p1, q1, z) == 0 and onSegment(p1, z, q1):
                # colinear and z is on segment p1,q1
                result[zi] = dist + distto(p1, z)
                #echo("win ", dist)
        dist += distto(p1, q1)
        #echo("step ", dist)
    #echo("lose")

proc zipplus(s1, s2: openArray[int]): seq[int] =
  var m = min(s1.len, s2.len)
  newSeq(result, m)
  for i in 0 ..< m:
    result[i] = s1[i] + s2[i]

proc traces(pts: seq[seq[Point]]): int =
    let 
        ints = intersects(pts)
        d1 = shorttr(pts[0], ints)
        d2 = shorttr(pts[1], ints)
        dx = zipplus(d1, d2)
    #echo("ints: ", ints)
    echo("d1: ", d1, " d2: ", d2, "dx ", dx)
    result = dx.min

when defined(test2):
    var pts = in2pts("R75,D30,R83,U83,L12,D49,R71,U7,L72\nU62,R66,U55,R34,D71,R55,D58,R83")
    echo("2 610?: ", traces(pts))
    pts = in2pts("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51\nU98,R91,D20,R16,D67,R40,U7,R15,U6,R7")
    echo("2 410?: ", traces(pts))

echo("Part 2: ", traces(in2pts(input)))
