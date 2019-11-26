

--  #123 @ 3,2: 5x4 means that claim ID 123 specifies a rectangle 3 inches from the left edge, 2 inches from the top edge, 5 inches wide, and 4 inches tall.

infile = io.open("2018_advent_3a.txt")
input = infile:read("a")
infile:close()

local rects = {}

for k, x, y, w, h in string.gmatch(input, "#(%d+) @ (%d+),(%d+): (%d+)x(%d+)") do
    rects[tonumber(k)] = {x = tonumber(x), y = tonumber(y), w = tonumber(w), h = tonumber(h)}
end


print("Input ", #rects, " rects")

local minx = 100000
local miny = 100000
local maxx = 0
local maxy = 0

for k,r in pairs(rects) do
    if r.x < minx then minx = r.x end
    if r.y < miny then miny = r.y end
    if (r.x + r.w) > maxx then maxx = (r.x + r.w) end
    if (r.y + r.h) > maxy then maxy = (r.y + r.h) end
end

print ("Extents: ", minx, miny, maxx, maxy)

overlaps = 0

for x = minx, maxx do
    for y = miny, maxy do
        local seen = false
        for k,r in pairs(rects) do
            if x >= r.x and x < r.x + r.w and y >= r.y and y < r.y + r.h then
                if seen then 
                    overlaps = overlaps + 1
                    break
                else
                    seen = true
                end
            end
        end
    end
end

print ("Overlaps ", overlaps)

