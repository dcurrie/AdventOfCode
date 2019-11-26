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

local minx =  100000000000
local maxx = -100000000000
local miny =  100000000000
local maxy = -100000000000
local minz =  100000000000
local maxz = -100000000000

local function readbots ()

    local infile = io.open(fname or "2018_advent_23a.txt")
    local line = infile:read("l")

    while line do
        -- pos=<0,0,0>, r=4
        local x,y,z,r = line:match("pos=<(%-?%d+),(%-?%d+),(%-?%d+)>, r=(%d+)")
        local tr = tonumber(r)
        local tz = tonumber(z)
        local ty = tonumber(y)
        local tx = tonumber(x)

        bots[#bots+1] = {x = tx, y = ty, z = tz, r = tr}
        if tr > maxr then
            maxr = tr
            maxb = bots[#bots]
        end
        minx = math.min(minx, tx)
        maxx = math.max(maxx, tx)
        miny = math.min(miny, ty)
        maxy = math.max(maxy, ty)
        minz = math.min(minz, tz)
        maxz = math.max(maxz, tz)
        line = infile:read("l")
    end

    printf("Read %d bots with max r = %d, x=%d..%d y=%d..%d z=%d..%d\n", #bots, maxr,
           minx, maxx, miny, maxy, minz, maxz)

    infile:close()
end

local function taxidist (p, b)
    return math.abs(p.x - b.x) + math.abs(p.y - b.y) + math.abs(p.z - b.z)
end

local m_n = 0  -- number of values
local m_oldM
local m_oldS

local mind =  100000000000
local maxd = -100000000000

local function statpush (x)

    mind = math.min(mind, x)
    maxd = math.max(maxd, x)

    m_n = m_n + 1

    -- See Knuth TAOCP vol 2, 3rd edition, page 232
    if (m_n == 1) then
        m_oldM = x
        m_newM = x
        m_oldS = 0.0
    else
        m_newM = m_oldM + (x - m_oldM) / m_n
        m_newS = m_oldS + (x - m_oldM) * (x - m_newM)
        -- set up for next iteration
        m_oldM = m_newM
        m_oldS = m_newS
    end
end

local function statmean ()
    return (m_n > 0) and m_newM or 0.0
end

local function statvariance ()
    return (m_n > 1) and (m_newS / (m_n - 1)) or 0.0
end

local function statstddev ()
    return math.sqrt(statvariance())
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

intersects = {}

local function part2a ()
    local n = #bots
    for i = 1, n do intersects[i] = 0 end
    for i = 1, n - 1 do
        for j = i + 1, n do
            local d = taxidist(bots[i], bots[j])
            statpush(d)
            if d < (bots[i].r + bots[j].r) then
                -- intersect
                intersects[i] = intersects[i] + 1
                intersects[j] = intersects[j] + 1
            end
        end
    end
end

local function part2 ()
    part2a()
    printf("Distance min %d mean %g max %d stdvar %g\n", 
            mind, statmean(), maxd, statvariance())
    if verbose then
        for i = 1, #bots do
            printf("%d\n", intersects[i])
        end
    end
end

local abs = math.abs

local function part2b ()
    -- this is a translation of seligman99's Python solution after I gave up
    -- https://pastebin.com/e7LdSNQe

    local x0 = minx
    local xn = maxx
    local y0 = miny
    local yn = maxy
    local z0 = minz
    local zn = maxz

    local dist = 1
    while dist < maxx - minx do
        dist = dist * 2
    end

    while true do
        if verbose then printf("Major loop: %d %d %d\n", dist, x0, xn) end
        local target_count = 0
        local best = nil
        local best_val = nil
        for x = x0, xn + 1, dist do
            for y = y0, yn + 1, dist do
                for z = z0, zn + 1, dist do
                    if verbose then printf("%d %d %d\n", x, y, z) end
                    local count = 0
                    local bdist
                    local calc
                    for b = 1, #bots do
                        local bx = bots[b].x
                        local by = bots[b].y
                        local bz = bots[b].z
                        bdist = bots[b].r
                        calc = abs(x - bx) + abs(y - by) + abs(z - bz)
                        -- we want integer math here (floor)
                        if (calc - bdist) // dist <= 0 then
                            count = count + 1
                        end
                    end
                    if verbose then printf("Count calc bdist: %d %d %d\n", count, calc, bdist) end
                    if count > target_count then
                        target_count = count
                        best_val = abs(x) + abs(y) + abs(z)
                        best = {x, y, z}
                    elseif count == target_count then
                        if best_val == nil or abs(x) + abs(y) + abs(z) < best_val then
                            best_val = abs(x) + abs(y) + abs(z)
                            best = {x, y, z}
                        end
                    end
                end
            end
        end

        if dist == 1 then
            printf("The max count I found was: %d with val % d\n", target_count, best_val)
            return best_val
        else
            x0, xn = best[1] - dist, best[1] + dist
            y0, yn = best[2] - dist, best[2] + dist
            z0, zn = best[3] - dist, best[3] + dist
            -- we want integer math here, floor
            dist = dist // 2
        end
    end
end


part1()
part2b()

print "Done"
