

--[[ gol

]]--

local rules = {}
local qrules = 0

local states = {}

local infile = io.open("2018_advent_12a.txt")

local init = infile:read("l") -- first line is special

-- prepend * postpend 22 dots to have room for growth
local growth = '......................'

states[0] =  growth .. init:match("initial state: (%p+)") .. growth

local line = infile:read("l")
while line do
    if line == '' then 
        -- punt
    else
        local pattern, result = line:match("(%p%p%p%p%p) => (%p)") -- e.g., ##... => .
        rules[pattern] = result
        qrules = qrules + 1
    end
    line = infile:read("l")
end
infile:close()

local width = string.len(states[0])

print ("Read ", qrules, " rules")
print ("Init ", width, states[0])

local next -- will hold the last row

for i = 1, 20 do
    local this = states[i-1]
    next = {".", "."}
    for c = 3, width - 2 do
        next[c] = rules[string.sub(this, c-2, c+2)]
    end
    next[width-1] = "."
    next[width] = "."
    states[i] = table.concat(next)
end

local result = 0

for i = 1, width do
    if next[i] == "#" then
        result = result + (i - 23)
    end
end


print ("Part1 ", result)

local rs = ''
local offset = 23

for i = 1, 1000 do
    local this = states[i-1]
    if this == states[i-2] then 
        print("Dup at ", i-1, i-2)
        break
    end
    next = {".", "."}
    for c = 3, width - 2 do
        next[c] = rules[string.sub(this, c-2, c+2)]
    end
    next[width-1] = "."
    next[width] = "."
    rs = table.concat(next)
    --print(rs)
    if string.sub(rs,1,22) == growth then
        rs = string.sub(rs,12) .. string.sub(growth,1,11)
        --print()
        --print(rs)
        offset = offset - 11
    end
    if i % 100 == 0 then
        local result = 0
        print("After itertation ", i, "sprites:")
        for j = 1, width do
            if next[j] == "#" then
                print(j - offset)
                result = result + (j - offset)
            end
        end
        print("Result ", result)
    end
    states[i] = rs
end

local result = 0

for i = 1, width do
    if next[i] == "#" then
        result = result + (i - offset)
    end
end

print ("Part2 ", result, rs) -- i * 5 + 219 = 25000000219

print "Done"
