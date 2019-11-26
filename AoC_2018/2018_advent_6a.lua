

--  

infile = io.open("2018_advent_6a.txt")
input = infile:read("a")
infile:close()

local points = {}

local minx = 10000000
local miny = 10000000
local maxx = -10000000
local maxy = -10000000

for x, y in string.gmatch(input, "(%d+), (%d+)") do
    local tx = tonumber(x)
    local ty = tonumber(y)
    points[#points+1] = {x = tx, y = ty}
    if tx < minx then minx = tx end
    if ty < miny then miny = ty end
    if tx > maxx then maxx = tx end
    if ty > maxy then maxy = ty end
end

print("Input ", #points, " points, from ", minx, miny, "to ", maxx, maxy)

local nearests = {} -- map of point number to number of points it "owns" by distance

function taxidist (p, x, y)
    return math.abs(p.x - x) + math.abs(p.y - y)
end

for x = minx, maxx do
    for y = miny, maxy do
        local nearest = 0
        local mindist = 10000000
        for i = 1, #points do
            local td = taxidist(points[i], x, y)
            if td < mindist then
                mindist = td
                nearest = i
            elseif td == mindist then
                nearest = 0
            end
        end
        if nearest ~= 0 then
            if x == minx or x == maxx or y == miny or y == maxy then
                nearests[nearest] = -1 -- infinite extent
            elseif nearests[nearest] == -1 then
                -- punt
            else
                nearests[nearest] = (nearests[nearest] or 0) + 1
            end
        end
    end
end

local maxni = 0

for i = 1, #points do
    local ni = (nearests[i] or 0)
    if ni > maxni then
        maxni = ni
    end
end

print ("Part 1, Max area is ", maxni)

-- What is the size of the region containing all locations which have a total distance to all given coordinates of less than 10000?

local rsz = 0

for x = minx, maxx do
    for y = miny, maxy do
        local ttd = 0
        for i = 1, #points do
            local td = taxidist(points[i], x, y)
            ttd = ttd + td
        end
        if ttd < 10000 then
            rsz = rsz + 1
        end
    end
end

print ("Part 2, Safe area is ", rsz)

print ("Done")

