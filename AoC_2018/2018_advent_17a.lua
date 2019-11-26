
--[[ --- Day 17: Reservoir Research ---

]]--

local printf = function(s,...)
    return io.write(s:format(...))
end

local fname = arg[1]
local verbose = (fname == '-v')
if verbose then fname = arg[2] end


-- arena[y][x] = '#' when there's a clay wall
--               '.' when it's open (sand)
--               '+' for spring
--               '|' for flowing water
--               '~' for standing water
--               '?' for out of bounds
local arena = {}
local xmin = 11000000
local xmax = -1
local ymin = 11000000
local ymax = -1

local function getxy (x, y, default)
    if y < ymin or y > ymax then
        return '?'
    end
    local row = arena[y]
    if x < xmin or x > xmax then
        return '?'
    elseif row == nil then
        return default or '?'
    else
        return row[x] or default or '?'
    end
end

local function setxy (x, y, s)
    if y < ymin then
        ymin = y
    elseif y > ymax then
        ymax = y
    else
        -- ok
    end
    local row = arena[y]
    if row == nil then
        row = {}
        arena[y] = row
    end
    if x < xmin then
        xmin = x
    elseif x > xmax then
        xmax = x
    else
        -- ok
    end
    row[x] = s
end

local function readarena ()

    local infile = io.open(fname or "2018_advent_17a.txt")
    local line = infile:read("l")

    while line do
        -- y=1350, x=517..542
        -- x=457, y=1253..1259
        if line:len() == 0 then 
            -- punt
        else
            local l,n,r,f,t = line:match("(%a)=(%d+), (%a)=(%d+)..(%d+)")
            if l == 'x' then
                local x = tonumber(n)
                if r == 'y' then
                    for i = tonumber(f), tonumber(t) do
                        setxy(x,i,'#')
                    end
                else
                    print("### Wrong r for x", r)
                end
            elseif l == 'y' then
                local y = tonumber(n)
                if r == 'x' then
                    for i = tonumber(f), tonumber(t) do
                        setxy(i,y,'#')
                    end
                else
                    print("### Wrong r for x", r)
                end
            else
                print("### Unknown l", l)
            end
        end
        line = infile:read("l")
    end
    infile:close()

    printf("Read %d..%d x %d..%d arena\n", xmin, xmax, ymin, ymax)
end

--[[
You scan a two-dimensional vertical slice of the ground nearby and discover that it is mostly 
sand with veins of clay. The scan only provides data with a granularity of square meters, but 
it should be good enough to determine how much water is trapped there. In the scan, x represents 
the distance to the right, and y represents the distance down. There is also a spring of water 
near the surface at x=500, y=0. The scan identifies which square meters are clay (your puzzle input).

The spring of water will produce water forever. Water can move through sand, but is blocked by 
clay. Water always moves down when possible, and spreads to the left and right otherwise, 
filling space that has clay on both sides and falling out otherwise.
]]--

local function printarena ()
    for y = ymin, ymax do
        for x = xmin, xmax do
            printf("%s", getxy(x,y,'.'))
        end
        printf("\n")
    end
end

local function part1 ()
    readarena()
    -- make room for spills
    xmin = xmin - 1
    xmax = xmax + 1
    -- make room for spring
    ymin = ymin - 1

    local water = xmax * ymax -- plenty to spare
    --print("Water max", water)

    setxy(500, ymin, '+') -- spring

    local work = {}
    local visited = {}

    local function pushtask (dir, x, y)
        local task = {dir=dir, x=x, y=y}
        work[#work+1] = task
    end

    local function poptask ()
        local task = work[#work]
        if task then work[#work] = nil end
        return task
    end

    local wet = 0
    local puddle = 0

    local function hashxy (x,y) return x * (ymax + 1) + y end

    local function drip (x, y)
        visited[hashxy(x,y)] = true
        local s = getxy(x, y, '.')
        if s == '#' or s == '~'then
            -- hit a floor
            return false
        elseif s == '.' then
            wet = wet + 1    -- new wet space
            setxy(x, y, '|') -- dripping state
            return true
        elseif s == '|' then
            return true
        else
            print("### Unexpected state", s)
            return false
        end
    end

    while water > 0 do

        startwater = water

        visited = {}

        local task = {dir='down', x=500, y=ymin}

        while task do
            if veryverbose then printf("Task: %s (%d,%d)\n", task.dir, task.x, task.y) end

            if task.dir == 'down' then
                local x = task.x
                local y = task.y + 1
                if y > ymax then
                    -- flow into the earth
                    task = poptask()
                elseif drip(x,y) then
                    -- continue dripping
                    task.y = y -- tail call
                else
                    pushtask('left', task.x, task.y)
                    task.dir = 'right' -- tail call
                end
            elseif task.dir == 'downL' then
                local x = task.x
                local y = task.y + 1
                if y > ymax then
                    -- flow into the earth
                    task = poptask()
                elseif visited[hashxy(x,y)] then
                    if drip(x,y) then
                        task = poptask()
                    else
                        task.dir = 'left' -- tail call
                    end
                elseif drip(x,y) then
                    -- continue dripping
                    task.dir = 'down'
                    task.y = y -- tail call
                else
                    task.dir = 'left' -- tail call
                end
            elseif task.dir == 'downR' then
                local x = task.x
                local y = task.y + 1
                if y > ymax then
                    -- flow into the earth
                    task = poptask()
                elseif visited[hashxy(x,y)] then
                    if drip(x,y) then
                        task = poptask()
                    else
                        task.dir = 'right' -- tail call
                    end
                elseif drip(x,y) then
                    -- continue dripping
                    task.dir = 'down'
                    task.y = y -- tail call
                else
                    task.dir = 'right' -- tail call
                end
            elseif task.dir == 'left' then
                local x = task.x - 1
                local y = task.y
                local v = false -- visited[hashxy(x,y)]
                if v or not drip(x,y) then
                    local l = getxy(x, y, '?')
                    if (l == '#') then
                        for i = task.x + 1, xmax do
                            local s = getxy(i, y, '.')
                            if (s == '#') then
                                for n = task.x, i-1 do
                                    setxy(n, y, '~')
                                    puddle = puddle + 1
                                    water = water - 1
                                end
                                break
                            elseif (s == '|')  then
                                if drip(i,y+1) then
                                    break -- still more to fill
                                else
                                    -- continue
                                end
                            elseif (s == '.') then
                                -- no wall
                                break
                            else
                                print("Wtf", s)
                            end
                        end
                    end
                    task = poptask()
                else
                    -- continue dripping
                    task.dir = 'downL'
                    task.x = x -- tail call
                end
            elseif task.dir == 'right' then
                local x = task.x + 1
                local y = task.y
                local v = false -- visited[hashxy(x,y)]
                if v or not drip(x,y) then
                    task = poptask()
                else
                    -- continue dripping
                    task.dir = 'downR'
                    task.x = x -- tail call
                end
            else
                print("### Unknown dir", task.dir)
            end
        end

        --break
        -- if water < xmax * ymax - 24 then break end -- debug
        if startwater == water then break end
    end

    if verbose then printarena() end

--    local wet2 = 0
--    for y = ymin, ymax do
--        for x = xmin, xmax do
--            local s = getxy(x,y,'.')
--            if s == '~' or s == '|' then
--                wet2 = wet2 + 1
--            end
--        end
--    end

    printf("Part 1 & 2: %d wet squares %d puddles\n", wet, puddle)

end

part1()

print "Done"
