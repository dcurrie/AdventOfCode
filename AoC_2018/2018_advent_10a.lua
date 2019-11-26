

--  sprites

local ltk = require "ltk" -- requires lua 5.3 as built

infile = io.open("2018_advent_10a.txt")
input = infile:read("a")
infile:close()

points = {}

for x, y, dx, dy in string.gmatch(input, "position=<%s*(%-?%d+),%s*(%-?%d+)> velocity=<%s*(%-?%d+),%s*(%-?%d+)>") do
    points[#points+1] = {x = tonumber(x), y = tonumber(y), dx = tonumber(dx), dy = tonumber(dy)}
end

print ("Read ", #points, " points")

local limit = 256  

local cwidth  = limit
local cheight = limit

local colors = {'white', 'black', 'red', 'blue'}


-- the canvas on which we draw
c = ltk.canvas {width = cwidth, height = cheight} 
c:pack()


for i = 1, #points do
    points[i].sprite = c:create_rectangle {i * 2 - 1,
                                           i * 2 - 1,
                                           i * 2 + 1, 
                                           i * 2 + 1,
                                           fill='black', 
                                           tags={''}}
end



while true do
    local maxx = 0
    local maxy = 0
    local minx = 1000000
    local miny = 1000000
    for i = 1, #points do
        local p = points[i]
        p.x = p.x + p.dx
        p.y = p.y + p.dy

       if p.x < minx then minx = p.x end
       if p.y < miny then miny = p.y end
       if p.x > maxx then maxx = p.x end
       if p.y > maxy then maxy = p.y end
    end

    if (maxx - minx) < limit and (maxy - miny) < limit then
        for i = 1, #points do
            local p = points[i]
            p.x = p.x - minx
            p.y = p.y - miny
            c:coords(p.sprite, p.x - 1, p.y - 1, p.x + 1, p.y + 1)
        end
        break
    end
end

function drawimg1()
    local drawfn
    drawfn = coroutine.wrap(function()
        for i = 1, #points do
            local p = points[i]
            c:move(p.sprite, p.dx, p.dy)
            p.x = p.x + p.dx
            p.y = p.y + p.dy
        end
        ltk.after{500, drawfn}
        coroutine.yield()
    end)
    ltk.after.idle(drawfn)
end

local pause = false

function drawimg()
    if not pause then
        for i = 1, #points do
            local p = points[i]
            c:move(p.sprite, p.dx, p.dy)
            p.x = p.x + p.dx
            p.y = p.y + p.dy
        end
    end
    ltk.after{500, drawimg}
end

b = ltk.button {text="Pause", command=function() pause = not pause end}

c:grid{row=1}
b:grid{row=2}

-- show window and all
ltk.update()

-- initial image
drawimg()

-- and run
ltk.mainloop()


-- print("Part 1: ", tick)

-- print("Part 2: ", tick)

print ("Done")

