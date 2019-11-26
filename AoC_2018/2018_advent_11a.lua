--  2018 AoC 11 -- grid

-- local inputgsn = 18

local inputgsn = 9445

--[[
Find the fuel cell's rack ID, which is its X coordinate plus 10.
Begin with a power level of the rack ID times the Y coordinate.
Increase the power level by the value of the grid serial number (your puzzle input).
Set the power level to itself multiplied by the rack ID.
Keep only the hundreds digit of the power level (so 12345 becomes 3; numbers with no hundreds digit become 0).
Subtract 5 from the power level.
]]--

function powerlevel (gsn, x, y)
    local rackID = x + 10
    local pwrlvl = rackID * y
    pwrlvl = pwrlvl + gsn
    pwrlvl = pwrlvl * rackID
    pwrlvl = (pwrlvl // 100) % 10
    return pwrlvl - 5
end

print ("Fuel cell at  122,79, grid serial number 57: power level -5 ", powerlevel(57, 122, 79) == -5)
print ("Fuel cell at 217,196, grid serial number 39: power level  0 ", powerlevel(39, 217,196) ==  0)
print ("Fuel cell at 101,153, grid serial number 71: power level  4 ", powerlevel(71, 101,153) ==  4)

racks = {}

for x = 1, 300 do 
    racks[x] = {}
    for y = 1, 300 do
        racks[x][y] = powerlevel(inputgsn, x, y)
    end
end

maxsum = 0
maxx = 0
maxy = 0

for x = 1, 298 do 
    for y = 1, 298 do
        local sum =   racks[x  ][y  ]
                    + racks[x+1][y  ]
                    + racks[x+2][y  ]
                    + racks[x  ][y+1]
                    + racks[x+1][y+1]
                    + racks[x+2][y+1]
                    + racks[x  ][y+2]
                    + racks[x+1][y+2]
                    + racks[x+2][y+2]
        if sum > maxsum then
            maxsum = sum
            maxx = x
            maxy = y
        end
    end
end


print("Part 1: ", maxx, maxy)

maxsum = 0
maxx = 0
maxy = 0
maxz = 0

if brute_force then

for z = 2, 300 do
    for x = 1, 300 + 1 - z do 
        for y = 1, 300 + 1 - z do
            local sum = 0
                for xi = x, x + z - 1 do
                    for yi = y, y + z - 1 do
                        sum = sum + racks[xi][yi]
                    end
                end
            if sum > maxsum then
                maxsum = sum
                maxx = x
                maxy = y
                maxz = z
            end
        end
    end
    print(z)
end

print("Part 2: ", maxx, maxy, maxz) -- 231  107 14

else

-- cheating...

--[[ using a summed area table https://en.wikipedia.org/wiki/Summed-area_table

The summed-area table can be computed efficiently in a single pass over the image, as the value 
in the summed-area table at (x, y) is just:

 I(x,y)=i(x,y)+I(x,y-1)+I(x-1,y)-I(x-1,y-1)

Once the summed-area table has been computed, evaluating the sum of intensities over any 
rectangular area requires exactly four array references regardless of the area size. That is, 
the notation in the figure at right, having A=(x0, y0), B=(x1, y0), C=(x0, y1) and D=(x1, y1), 
the sum of i(x,y) over the rectangle spanned by A, B,C and D

AB
CD
 is:

sum {x0..x1,y0..y1} i(x,y) = I(D)+I(A)-I(B)-I(C)}

]]

-- make summed-area table

sat = {}

local function zob (t, k) return 0 end

sat[0] = setmetatable({}, {__index = zob})

for x = 1, 300 do 
    sat[x] = setmetatable({}, {__index = zob})
    for y = 1, 300 do
        sat[x][y] = racks[x][y] + sat[x][y-1] + sat[x-1][y] - sat[x-1][y-1]
    end
end

-- do the calc

for z = 2, 300 do
    for x = 1, 300 + 1 - z do 
        for y = 1, 300 + 1 - z do
            local sum = sat[x + z - 1][y + z - 1] + sat[x-1][y-1]
                      - sat[x-1][y + z - 1] - sat[x + z - 1][y-1]
            if sum > maxsum then
                maxsum = sum
                maxx = x
                maxy = y
                maxz = z
            end
        end
    end
end

print("Part 2: ", maxx, maxy, maxz) -- 231  107 14

end

print ("Done")
