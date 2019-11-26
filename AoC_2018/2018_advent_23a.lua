--[[ --- Day 23: Experimental Emergency Teleportation ---

]]--

local printf = function(s,...)
    return io.write(s:format(...))
end

local fname = arg[1]
local verbose = (fname == '-v')
if verbose then fname = arg[2] end

local bots = {}

local maxr = 0
local maxb

local function readbots ()

    local infile = io.open(fname or "2018_advent_23a.txt")
    local line = infile:read("l")

    while line do
        -- pos=<0,0,0>, r=4
        local x,y,z,r = line:match("pos=<(%-?%d+),(%-?%d+),(%-?%d+)>, r=(%d+)")
        local tr = tonumber(r)
        bots[#bots+1] = {x = tonumber(x), y = tonumber(y), z = tonumber(z), r = tr}
        if tr > maxr then
            maxr = tr
            maxb = bots[#bots]
        end
        line = infile:read("l")
    end

    printf("Read %d bots with max r = %d\n", #bots, maxr)

    infile:close()
end

local function taxidist (p, b)
    return math.abs(p.x - b.x) + math.abs(p.y - b.y) + math.abs(p.z - b.z)
end

local function part1 ()
    readbots()
    local count = 0
    for i = 1, #bots do
        if taxidist(maxb, bots[i]) <= maxr then
            count = count + 1
        end
    end
    printf("Part1: bots in range: %d\n", count)
end

part1()

print "Done"
