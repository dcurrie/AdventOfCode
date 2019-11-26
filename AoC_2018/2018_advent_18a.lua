--[[ --- Day 18: Settlers of The North Pole ---

]]--

local printf = function(s,...)
    return io.write(s:format(...))
end

local fname = arg[1]
local verbose = (fname == '-v')
if verbose then fname = arg[2] end


-- arena[y][x] = '#' lumberyard
--               '.' open ground
--               '|' trees
--               '?' for out of bounds
local xmin = 1
local xmax = 50
local ymin = 1
local ymax = 50

local arena_fm
local arena_to

local function getxy (x, y)
    return arena_fm[y][x]
end

local function setxy (x, y, s)
    arena_to[y][x] = s
end

local function initarena ()
    local t = {}
    for y = ymin - 1, ymax + 1 do
        local row = {}
        row[xmin - 1] = '?'
        row[xmax + 1] = '?'
        if y < ymin or y > ymax then 
            for x = xmin, xmax do
                row[x] = '?'
            end
        end
        t[y] = row
    end
    return t
end

local function readarena ()

    local infile = io.open(fname or "2018_advent_18a.txt")
    local line = infile:read("l")
    
    xmax = line:len()
    ymax = xmax
    
    arena_fm = initarena()
    arena_to = initarena()

    local y = 1

    while line do
        if line:len() ~= xmax then 
            print("Line length incorrect: ", line:len())
            break -- punt
        else
            local row = arena_fm[y]
            for x = 1, xmax do
                row[x] = line:sub(x,x)
            end
        end
        y = y + 1
        line = infile:read("l")
    end
    infile:close()

    if y ~= ymax + 1 then print("Unexpected number of lines: ", y - 1) end

    printf("Read %d..%d x %d..%d arena\n", xmin, xmax, ymin, ymax)
end

local function printarena (a)
    for y = ymin, ymax do
        local row = a[y]
        for x = xmin, xmax do
            printf("%s", row[x])
        end
        printf("\n")
    end
end

local cellval = {['|']= 1, ['#']= 0x10, ['.']= 0x100, ['?']= 0}

--[[
An open acre will become filled with trees if three or more adjacent acres contained trees. Otherwise, nothing happens.
An acre filled with trees will become a lumberyard if three or more adjacent acres were lumberyards. Otherwise, nothing happens.
An acre containing a lumberyard will remain a lumberyard if it was adjacent to at least one other lumberyard and at least one acre containing trees. Otherwise, it becomes open.
]]

local function step()
    for y = ymin, ymax do
        for x = xmin, xmax do
            local t = '?'
            local s = getxy(x,y)
            local v = cellval[getxy(x-1, y-1)]
                    + cellval[getxy(x  , y-1)]
                    + cellval[getxy(x+1, y-1)]
                    + cellval[getxy(x-1, y  )]
                    + cellval[getxy(x+1, y  )]
                    + cellval[getxy(x-1, y+1)]
                    + cellval[getxy(x  , y+1)]
                    + cellval[getxy(x+1, y+1)]
            local trees =  v       & 0xf
            local yards = (v >> 4) & 0xf
            local empty = (v >> 8) & 0xf
            if s == '.' then
                if trees >= 3 then
                    t = '|'
                else
                    t = '.'
                end
            elseif s == '|' then
                if yards >= 3 then
                    t = '#'
                else
                    t = '|'
                end
            elseif s == '#' then
                if yards >= 1 and trees >= 1 then
                    t = '#'
                else
                    t = '.'
                end
            else
                print("ERROR wtf", s, x, y)
            end
            setxy(x, y, t)
        end
    end
end


local function part1 (n)
    readarena()

    if verbose then printarena(arena_fm) end

    for i = 1, n do
        step()
        arena_fm, arena_to = arena_to, arena_fm
        if verbose then printarena(arena_fm) end
    end

--[[
    After 10 minutes, there are 37 wooded acres and 31 lumberyards. Multiplying the number of 
    wooded acres by the number of lumberyards gives the total resource value after ten minutes:
     37 * 31 = 1147.

    What will the total resource value of the lumber collection area be after 10 minutes?
]]
    local trees = 0
    local yards = 0
    for y = ymin, ymax do
        local row = arena_fm[y]
        for x = xmin, xmax do
            local s = row[x]
            if s == '|' then
                trees = trees + 1
            elseif s == '#' then
                yards = yards + 1
            end
        end
    end
    printf("Part1 resource value = %d x %d = %d\n", trees, yards, trees * yards)

end

part1(10)

print "Done"
