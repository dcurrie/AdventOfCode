
--[[ --- Day 22: Mode Maze ---


The geologic index can be determined using the first rule that applies from the list below:

The region at 0,0 (the mouth of the cave) has a geologic index of 0.
The region at the coordinates of the target has a geologic index of 0.
If the region's Y coordinate is 0, the geologic index is its X coordinate times 16807.
If the region's X coordinate is 0, the geologic index is its Y coordinate times 48271.
Otherwise, the region's geologic index is the result of multiplying the erosion levels of the regions at X-1,Y and X,Y-1.
A region's erosion level is its geologic index plus the cave system's depth, all modulo 20183. Then:

If the erosion level modulo 3 is 0, the region's type is rocky.
If the erosion level modulo 3 is 1, the region's type is wet.
If the erosion level modulo 3 is 2, the region's type is narrow.

]]--

local printf = function(s,...)
    return io.write(s:format(...))
end


-- inputs:
local depth_in = 7863
local target_x = 14
local target_y = 760

local ysize = 1023 -- arbitrary

local function pos2hash (x, y)
    return (x * ysize) + y
end

local function hash2pos (u)
    return u // ysize, u % ysize
end

local giht = {} -- geologic index hash table

local erosionlevel

local function gi (depth, x, y)
    local u = pos2hash (x, y)
    local p = giht[u]
    if p == nil then
        if x == 0 then
            p = y * 48271
        elseif y == 0 then
            p = x * 16807
        elseif x == target_x and y == target_y then
            p = 0
        else
            p = erosionlevel(depth, x-1, y) * erosionlevel(depth, x, y-1)
        end
        giht[u] = p
    end
    return p
end

erosionlevel = function (depth, x, y)
    return (gi(depth, x, y) + depth) % 20183
end

local function regiontype (depth, x, y)
    return erosionlevel(depth, x, y) % 3
end

--[[
For example, suppose the cave system's depth is 510 and the target's coordinates are 10,10. Using % to represent the modulo operator, the cavern would look as follows:

At 0,0, the geologic index is 0. The erosion level is (0 + 510) % 20183 = 510. The type is 510 % 3 = 0, rocky.
At 1,0, because the Y coordinate is 0, the geologic index is 1 * 16807 = 16807. The erosion level is (16807 + 510) % 20183 = 17317. The type is 17317 % 3 = 1, wet.
At 0,1, because the X coordinate is 0, the geologic index is 1 * 48271 = 48271. The erosion level is (48271 + 510) % 20183 = 8415. The type is 8415 % 3 = 0, rocky.
At 1,1, neither coordinate is 0 and it is not the coordinate of the target, so the geologic index is the erosion level of 0,1 (8415) times the erosion level of 1,0 (17317), 8415 * 17317 = 145722555. The erosion level is (145722555 + 510) % 20183 = 1805. The type is 1805 % 3 = 2, narrow.
At 10,10, because they are the target's coordinates, the geologic index is 0. The erosion level is (0 + 510) % 20183 = 510. The type is 510 % 3 = 0, rocky.
]]--

assert(gi(510,0,0) == 0)
assert(erosionlevel(510,0,0) == 510)
assert(regiontype(510,0,0) == 0)

assert(gi(510,1,0) == 16807)
assert(erosionlevel(510,1,0) == 17317)
assert(regiontype(510,1,0) == 1)

assert(gi(510,0,1) == 48271)
assert(erosionlevel(510,0,1) == 8415)
assert(regiontype(510,0,1) == 0)

assert(gi(510,1,1) == 145722555)
assert(erosionlevel(510,1,1) == 1805)
assert(regiontype(510,1,1) == 2)

assert(gi(510,target_x,target_y) == 0)
assert(erosionlevel(510,target_x,target_y) == 510)
assert(regiontype(510,target_x,target_y) == 0)


--[[ using a summed area table https://en.wikipedia.org/wiki/Summed-area_table

The summed-area table can be computed efficiently in a single pass over the image, as the value 
in the summed-area table at (x, y) is just:

 I(x,y)=i(x,y)+I(x,y-1)+I(x-1,y)-I(x-1,y-1)

Once the summed-area table has been computed, evaluating the sum of intensities over any 
rectangular area requires exactly four array references regardless of the area size. That is, 
the notation in the figure at right, having A=(x0, y0), B=(x1, y0), C=(x0, y1) and D=(x1, y1), 
the sum of i(x,y) over the rectangle spanned by A, B,C and D

AB
CD
 is:

sum {x0..x1,y0..y1} i(x,y) = I(D)+I(A)-I(B)-I(C)}

]]

local function sumarea (depth, x0, y0, xn, yn)

    sat = {} -- make summed-area table
    local function zob (t, k) return 0 end -- default when we index off edges (zero out of bounds)
    sat[-1] = setmetatable({}, {__index = zob})

    for x = x0, xn do
        sat[x] = setmetatable({}, {__index = zob})
        for y = y0, yn do
            sat[x][y] = regiontype(depth, x, y) + sat[x][y-1] + sat[x-1][y] - sat[x-1][y-1]
        end
    end

    -- do the calc

    return sat[xn][yn]
end

local function printarea (depth, x0, y0, xn, yn)
    for y = y0, yn do
        for x = x0, xn do
            local r = regiontype(depth, x, y)
            local c = ({[0]='.', '=', '|'})[r]
            printf("%s",c)
        end
        print()
    end
end

--[[ test
target_x = 10
target_y = 10
printarea(510, 0, 0, 10, 10)
print(sumarea(510, 0, 0, 10, 10))
]]--

giht = {}
printf("Part 1: %d\n", sumarea(depth_in, 0, 0, target_x, target_y))
