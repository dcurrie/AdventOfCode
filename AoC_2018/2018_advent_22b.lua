
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


local verbose = (arg[1] == '-v')


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

--[[
As you leave, he hands you some tools: a torch and some climbing gear. You can't equip both tools at once, but you can choose to use neither.

Tools can only be used in certain regions:

In rocky regions, you can use the climbing gear or the torch. You cannot use neither (you'll likely slip and fall).
In wet regions, you can use the climbing gear or neither tool. You cannot use the torch (if it gets wet, you won't have a light source).
In narrow regions, you can use the torch or neither tool. You cannot use the climbing gear (it's too bulky to fit).
You start at 0,0 (the mouth of the cave) with the torch equipped and must reach the target coordinates as quickly as possible. 
The regions with negative X or Y are solid rock and cannot be traversed. 
The fastest route might involve entering regions beyond the X or Y coordinate of the target.

You can change your currently equipped tool or put both away if your new equipment would be valid 
for your current region. Switching to using the climbing gear, torch, or neither always takes 
seven minutes, regardless of which tools you start with. (For example, if you are in a rocky 
region, you can switch from the torch to the climbing gear, but you cannot switch to neither.)
]]--

-- Tools
local tool0  = 0 -- none
local torch  = 1
local cgear  = 2

local H = 1000000000  -- huge, for impossible situations

local costt = 
{ -- fmtype totype   tool     cost newtools
  [ 0 * 9 + 0 * 3 + tool0 ] = { H, tool0 }, -- rocky  to rocky
  [ 0 * 9 + 0 * 3 + torch ] = { 0, torch }, -- rocky  to rocky
  [ 0 * 9 + 0 * 3 + cgear ] = { 0, cgear }, -- rocky  to rocky

  [ 0 * 9 + 1 * 3 + tool0 ] = { H, tool0 }, -- rocky  to wet
  [ 0 * 9 + 1 * 3 + torch ] = { 7, cgear }, -- rocky  to wet
  [ 0 * 9 + 1 * 3 + cgear ] = { 0, cgear }, -- rocky  to wet

  [ 0 * 9 + 2 * 3 + tool0 ] = { H, tool0 }, -- rocky  to narrow
  [ 0 * 9 + 2 * 3 + torch ] = { 0, torch }, -- rocky  to narrow
  [ 0 * 9 + 2 * 3 + cgear ] = { 7, torch }, -- rocky  to narrow

  [ 1 * 9 + 0 * 3 + tool0 ] = { 7, cgear }, -- wet    to rocky
  [ 1 * 9 + 0 * 3 + torch ] = { H, torch }, -- wet    to rocky
  [ 1 * 9 + 0 * 3 + cgear ] = { 0, cgear }, -- wet    to rocky

  [ 1 * 9 + 1 * 3 + tool0 ] = { 0, tool0 }, -- wet    to wet
  [ 1 * 9 + 1 * 3 + torch ] = { H, torch }, -- wet    to wet
  [ 1 * 9 + 1 * 3 + cgear ] = { 0, cgear }, -- wet    to wet

  [ 1 * 9 + 2 * 3 + tool0 ] = { 0, tool0 }, -- wet    to narrow
  [ 1 * 9 + 2 * 3 + torch ] = { H, torch }, -- wet    to narrow
  [ 1 * 9 + 2 * 3 + cgear ] = { 7, tool0 }, -- wet    to narrow

  [ 2 * 9 + 0 * 3 + tool0 ] = { 7, torch }, -- narrow to rocky
  [ 2 * 9 + 0 * 3 + torch ] = { 0, torch }, -- narrow to rocky
  [ 2 * 9 + 0 * 3 + cgear ] = { H, cgear }, -- narrow to rocky

  [ 2 * 9 + 1 * 3 + tool0 ] = { 0, tool0 }, -- narrow to wet
  [ 2 * 9 + 1 * 3 + torch ] = { 7, tool0 }, -- narrow to wet
  [ 2 * 9 + 1 * 3 + cgear ] = { H, cgear }, -- narrow to wet

  [ 2 * 9 + 2 * 3 + tool0 ] = { 0, tool0 }, -- narrow to narrow
  [ 2 * 9 + 2 * 3 + torch ] = { 0, torch }, -- narrow to narrow
  [ 2 * 9 + 2 * 3 + cgear ] = { H, cgear }  -- narrow to narrow
}


local function cost (fmregiontype, toregiontype, tools)
    local hash = (fmregiontype * 9) + (toregiontype * 3) + tools
    return costt[hash]
end

local function state2hash (x, y, tools)
    return pos2hash(x,y) * 3 + tools
end

local function hash2state (h)
    local x,y = hash2pos(h // 3)
    return x, y, h % 3
end

local heap = require "minheap"

function route (depth, xn, yn)

    local goal = state2hash(xn, yn, torch) -- with tool in hand

    local incrs = {N={x=0,y=-1}, E={x=1,y=0}, S={x=0,y=1}, W={x=-1,y=0}}

    local openSet = heap.new()

    -- For each node, the cost of getting from the start node to that node.
    -- gScore := map with default value of Infinity
    local function iob (t, k) return 10000000000 end -- default (infinity out of bounds)
    gScore = setmetatable({}, {__index = iob})

    -- The cost of going from start to start with torch is zero.
    gScore[state2hash(0, 0, torch)] = 0

    openSet:push(state2hash(0, 0, torch), 0) -- start at 0,0 with torch in hand

    while not openSet:isempty() do
        local u,_ = openSet:pop()
        local ux,uy,ut = hash2state(u)
        for _,dxdy in pairs(incrs) do
            local y = uy + dxdy.y
            local x = ux + dxdy.x
            if x >= 0 and y >= 0 and x < (3 * xn) and y < (3 * yn) then
                local inct = cost(regiontype(depth, ux, uy), regiontype(depth, x, y), ut)
                local alt = gScore[u] + inct[1] + 1
                for i = 2, #inct do
                    if verbose then printf("Cost from (%d,%d) w/%d to (%d,%d)@%d = %d w/%d\n",
                                     ux, uy, ut, x, y, regiontype(depth, x, y), inct[1], inct[i]) end
                    local v = state2hash(x, y, inct[i])
                    --if verbose then printf("Alt %d %d \n", alt, gScore[v]) end
                    if alt < gScore[v] then
                        if verbose then printf("From (%d,%d) w/%d to (%d,%d) w/%d; %d -> %d\n",
                            ux, uy, ut, x, y, inct[i], gScore[v], alt) end
                        gScore[v] = alt
                        openSet:decr(v, alt)
                    end
                end
            end
        end
    end

    local s1 = gScore[goal]
    local s2 = gScore[state2hash(xn, yn, cgear)] + 7

    printf("Part 2: %d %d\n", s1, s2)

    return s1, s2
end

--[[ test 
giht = {}
target_x = 10
target_y = 10
printf("Test 1: %d\n", sumarea(510, 0, 0, target_x, target_y))
printf("Test 2: %d\n", route(510, target_x, target_y))
]]

route(depth_in, target_x, target_y)
