#!/usr/bin/env python3
import re, sys
from heapq import heapify, heappush, heappop

# https://gist.github.com/pdewacht/fa7aa7e60952c6d67956599d6d4af360

class Bot:
    def __init__(self, x, y, z, r):
        self.x = x
        self.y = y
        self.z = z
        self.r = r

    def range_clips_with_cube(self, x1, y1, z1, x2, y2, z2):
        # Does the octahedron defined by this bot
        # overlap with the cube (x1,y1,z1)-(x2,y2,z2)?
        assert x1 <= x2 and y1 <= y2 and z1 <= z2
        dist = 0
        if self.x < x1:   dist += x1 - self.x
        elif self.x > x2: dist += self.x - x2
        if self.y < y1:   dist += y1 - self.y
        elif self.y > y2: dist += self.y - y2
        if self.z < z1:   dist += z1 - self.z
        elif self.z > z2: dist += self.z - z2
        return dist <= self.r

bots = [Bot(*map(int, re.findall(r'-?\d+', line, re.ASCII)))
        for line in sys.stdin]

min_x = min(b.x for b in bots)
max_x = max(b.x for b in bots)
min_y = min(b.y for b in bots)
max_y = max(b.y for b in bots)
min_z = min(b.z for b in bots)
max_z = max(b.z for b in bots)

s = 1  # size of the cube, a power of two
while s < max(max_x - min_x, max_y - min_y, max_z - min_z):
    s *= 2

q = []  # min-heap

def add(x1, y1, z1):
    x2 = x1 + s - 1
    y2 = y1 + s - 1
    z2 = z1 + s - 1
    in_range = 0
    for b in bots:
        if b.range_clips_with_cube(x1, y1, z1, x2, y2, z2):
            in_range += 1
    if in_range > 0:
        # Distance from (0,0,0) to the closest corner of the cube
        dist = (min(abs(x1), abs(x2))
                + min(abs(y1), abs(y2))
                + min(abs(z1), abs(z2)))
        heappush(q, (-in_range, dist, s, x1, y1, z1))

add(min_x, min_y, min_z)
while q:
    score, dist, s, x, y, z = heappop(q)
    if s == 1:
        print("best location:", (x, y, z))
        print("bots in range:", -score)
        print("distance from origin:", dist)
        break

    s //= 2
    add(x, y, z)
    add(x, y, z+s)
    add(x, y+s, z)
    add(x, y+s, z+s)
    add(x+s, y, z)
    add(x+s, y, z+s)
    add(x+s, y+s, z)
    add(x+s, y+s, z+s)
