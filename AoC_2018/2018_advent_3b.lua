

--  #123 @ 3,2: 5x4 means that claim ID 123 specifies a rectangle 3 inches from the left edge, 2 inches from the top edge, 5 inches wide, and 4 inches tall.

infile = io.open("2018_advent_3a.txt")
input = infile:read("a")
infile:close()

local rects = {}

for k, x, y, w, h in string.gmatch(input, "#(%d+) @ (%d+),(%d+): (%d+)x(%d+)") do
    rects[tonumber(k)] = {x = tonumber(x), y = tonumber(y), w = tonumber(w), h = tonumber(h)}
end

print("Input ", #rects, " rects")

overlapr = {}

function roverlap (r1, r2)
    return ((r1.x < (r2.x + r2.w)) and (r2.x < (r1.x + r1.w))
        and (r1.y < (r2.y + r2.h)) and (r2.y < (r1.y + r1.h)))
end

for i = 1, #rects do
    for j = i + 1, #rects do
        if roverlap(rects[i], rects[j]) then
            overlapr[i] = true
            overlapr[j] = true
        end
    end
end

for i = 1, #rects do
    if not overlapr[i] then
        print ("No overlaps: ", i)
    end
end

print ("Done ")

