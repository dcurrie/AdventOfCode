import strutils, sequtils, strscans, os, sets, tables, parseutils, sugar

type Coord = tuple[x:int, y:int, z:int]

const neightbors =
    [(-1,-1,-1),
     (-1,-1, 0),
     (-1,-1, 1),
     (-1, 0,-1),
     (-1, 0, 0),
     (-1, 0, 1),
     (-1, 1,-1),
     (-1, 1, 0),
     ( 0, 1, 1), # oops! -- that's why!? s.b. (-1, 1, 1)
     ( 0,-1,-1),
     ( 0,-1, 0),
     ( 0,-1, 1),
     ( 0, 0,-1),
     ( 0, 0, 1),
     ( 0, 1,-1),
     ( 0, 1, 0),
     ( 0, 1, 1),
     ( 1,-1,-1),
     ( 1,-1, 0),
     ( 1,-1, 1),
     ( 1, 0,-1),
     ( 1, 0, 0),
     ( 1, 0, 1),
     ( 1, 1,-1),
     ( 1, 1, 0),
     ( 1, 1, 1)
    ]

proc count_neighbors () =
    for (dx,dy,dz) in neightbors:
        echo((dx,dy,dz))

count_neighbors()
