--[[ --- Day 20: A Regular Map ---

]]--

local printf = function(s,...)
    return io.write(s:format(...))
end

local fname = arg[1]
local verbose = (fname == '-v')
if verbose then fname = arg[2] end


-- arena[y][x] = '#' wall
--               '.' room
--               '-' wall
--               '|' wall
--               '?' for out of bounds or unknown
local xmin = 500
local xmax = 500
local ymin = 500
local ymax = 500

local arena = {}

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


local function initarena ()
    local t = {}
    return t
end

local regex

local function readregex ()

    local infile = io.open(fname or "2018_advent_20a.txt")
    local line = infile:read("l")
    local len = line:len()
    
    if line:sub(1,1) == '^' and line:sub(len, len) == '$' then
        printf("Read %d char regex\n", len)
        regex = line
    else
        printf("Malformed regex %s ... %s\n", line:sub(1,1), line:sub(len, len))
    end

    infile:close()
end

local function printarena (a)
    for y = ymin, ymax do
        for x = xmin, xmax do
            printf("%s", getxy(x,y,'?'))
        end
        printf("\n")
    end
end

local function addposnd (to, fm, incr)
    to.x = fm.x + incr.x
    to.y = fm.y + incr.y
end

local incrs = {N={x=0,y=-1}, E={x=1,y=0}, S={x=0,y=1}, W={x=-1,y=0}}

local sides = {N={{x=1,y=0}, {x=-1,y=0}},
               S={{x=1,y=0}, {x=-1,y=0}},
               E={{x=0,y=1}, {x=0,y=-1}},
               W={{x=0,y=1}, {x=0,y=-1}}}

local doors = {N='-', E='|', S='-', W='|'}

local specs = {['('] = true, ['|'] = true, [')'] = true}

local function pos2hash (x, y)
    return (x - xmin) * (ymax - ymin + 1) + (y - ymin)
end

local function hash2pos (u)
    return xmin + u // (ymax - ymin + 1), ymin + u % (ymax - ymin + 1)
end

local heap = require "minheap"

function distances (unit)
    local source = pos2hash(unit.x, unit.y)
    local dist = {[source]=0}
    local Q = heap.new()
    Q:push(source, 0)

    while not Q:isempty() do
        local u,_ = Q:pop()
        local ux,uy = hash2pos(u)
        for _,dxdy in pairs(incrs) do
            local y = uy + dxdy.y
            local x = ux + dxdy.x
            if getxy(x,y) == '-' or getxy(x,y) == '|' then
                local alt = dist[u] + 1
                local v = pos2hash(x+dxdy.x, y+dxdy.y)
                if alt < (dist[v] or 100000000) then
                    dist[v] = alt
                    Q:decr(v, alt)
                end
            end
        end
    end

    return dist -- maps pos2hash(x,y) to distance
end

local function part1 ()
    readregex()

    local stack = {}
    local posn = {x=500, y=500}
    local wall = {x=200, y=2500}

    setxy(500,500,'X')

    --if verbose then printf("Regex: '%s'\n", regex) end 

    for i = 2, regex:len() - 1 do
        local c = regex:sub(i,i)
        --if verbose then printf("Read char '%s' at %d, %d\n", c, i, i) end
        if specs[c] then
            if c == '(' then
                stack[#stack+1] = {x = posn.x, y = posn.y}
            elseif c == '|' then
                top = stack[#stack]
                posn = {x = top.x, y = top.y}
            else -- c == ')'
                posn = stack[#stack]
                stack[#stack] = nil
            end
        else
            addposnd(posn,posn,incrs[c])    -- one step
            setxy(posn.x, posn.y, doors[c]) -- add a door
            addposnd(wall,posn,sides[c][1]) -- one side
            setxy(wall.x, wall.y, '#')      -- add a wall
            addposnd(wall,posn,sides[c][2]) -- other side
            setxy(wall.x, wall.y, '#')      -- add a wall
            addposnd(posn,posn,incrs[c])    -- second step
            setxy(posn.x, posn.y, '.')      -- add a room
        end

        --if verbose then printarena(arena); printf("\n") end
    end
    
    -- if verbose then printarena(arena) end

    for y = ymin, ymax do
        for x = xmin, xmax do
            if getxy(x,y) == '?' then
                setxy(x,y,'#')
            end
        end
    end

    if verbose then printarena(arena) end

    local dist = distances({x=500, y=500})

    local maxdist = 0

    for y = ymin, ymax do
        for x = xmin, xmax do
            if getxy(x,y) == '.' then
                local d = dist[pos2hash(x,y)]
                if d > maxdist then maxdist = d end
            end
        end
    end

    local maxdist2 = 0

    for k,v in pairs(dist) do
        if verbose then
            local x,y = hash2pos(k)
            printf("to (%3d,%3d) is %3d\n", x, y, v)
        end
        if v > maxdist2 then maxdist2 = v end
    end

    printf("Part1: max distance is %d %d\n", maxdist, maxdist2)

    local count = 0

    for k,v in pairs(dist) do
        if v >= 1000 then count = count + 1 end
    end

    printf("Part2: paths with 1000 doors %d\n", count)

end

part1()

print "Done"
