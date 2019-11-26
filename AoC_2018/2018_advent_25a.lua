--[[ --- Day 25: Four-Dimensional Adventure ---

]]--

local printf = function(s,...)
    return io.write(s:format(...))
end

local abs, min, max = math.abs, math.min, math.max

local fname = arg[1]
local verbose = (fname == '-v')
if verbose then fname = arg[2] end

local stars = {}

local minx =  100000000000
local maxx = -100000000000
local miny =  100000000000
local maxy = -100000000000
local minz =  100000000000
local maxz = -100000000000
local mint =  100000000000
local maxt = -100000000000

local function readstars ()

    local infile = io.open(fname or "2018_advent_25a.txt")
    local line = infile:read("l")

    local n = 0

    while line do
        -- -2,3,-2,1
        local x,y,z,t = line:match("(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+)")
        local tt = tonumber(t)
        local tz = tonumber(z)
        local ty = tonumber(y)
        local tx = tonumber(x)

        n = n + 1

        stars[n] = {x = tx, y = ty, z = tz, t = tt, i=n, parent=n, size=1} -- i parent and size are for union-find

        minx = min(minx, tx)
        maxx = max(maxx, tx)
        miny = min(miny, ty)
        maxy = max(maxy, ty)
        minz = min(minz, tz)
        maxz = max(maxz, tz)
        mint = min(mint, tt)
        maxt = max(maxt, tt)
        
        line = infile:read("l")
    end

    printf("Read %d stars with x=%d..%d y=%d..%d z=%d..%d t=%d..%d\n", n,
           minx, maxx, miny, maxy, minz, maxz, mint, maxt)

    infile:close()
end

local function taxidist4D (p, b)
    return abs(p.x - b.x) + abs(p.y - b.y) + abs(p.z - b.z) + abs(p.t - b.t)
end

-- union find: https://en.wikipedia.org/wiki/Disjoint-set_data_structure

local function find(x) -- using path splitting
    while x.parent ~= x.i do
        local p = stars[x.parent]
        x, x.parent = p, p.parent
    end
    return x.i
end

local function union (x, y)

    local xRooti = find(x)
    local yRooti = find(y)
 
    if xRooti == yRooti then      
       return -- x and y are already in the same set
    end

    -- x and y are not in same set, so we merge them

    local xRoot = stars[xRooti]
    local yRoot = stars[yRooti]

    if xRoot.size < yRoot.size then
        xRoot, yRoot = yRoot, xRoot -- swap xRoot and yRoot
    end
 
   -- merge yRoot into xRoot
   yRoot.parent = xRoot.i
   xRoot.size = xRoot.size + yRoot.size
end

local function part1 ()
    readstars()

    for i = 1, #stars do
        local si = stars[i]
        for j = i + 1, #stars do
            local sj = stars[j]
            if find(si) ~= find(sj) and taxidist4D(si, sj) <= 3 then
                 union(si, sj)
             end
         end
     end

     local count = 0

    for i = 1, #stars do
        if find(stars[i]) == i then count = count + 1 end
    end

    printf("Part1: %d\n", count)
end


part1()


print "Done"
