

--[[
The polymer is formed by smaller units which, when triggered, react with each other such that two adjacent units of the same type and opposite polarity are destroyed. Units' types are represented by letters; units' polarity is represented by capitalization. For instance, r and R are units with the same type but opposite polarity, whereas r and s are entirely different types and do not react.

For example:

In aA, a and A react, leaving nothing behind.
In abBA, bB destroys itself, leaving aA. As above, this then destroys itself, leaving nothing.
In abAB, no two adjacent units are of the same type, and so nothing happens.
In aabAAB, even though aa and AA are of the same type, their polarities match, and so nothing happens.
Now, consider a larger example, dabAcCaCBAcCcaDA:

dabAcCaCBAcCcaDA  The first 'cC' is removed.
dabAaCBAcCcaDA    This creates 'Aa', which is removed.
dabCBAcCcaDA      Either 'cC' or 'Cc' are removed (the result is the same).
dabCBAcaDA        No further actions can be taken.
After all possible reactions, the resulting polymer contains 10 units.

How many units remain after fully reacting the polymer you scanned? 
]]--

infile = io.open("2018_advent_5a.txt")
input = infile:read("l") -- Note: 'a' includes EOL char
infile:close()


function reduc1 (s)
    local t = {} -- substrings 
    local i = 1
    local n = s:len()
    while i < n do
        local c1 = s:byte(i)
        local c2 = s:byte(i+1)
        if (c1 ~ c2) == 0x20 then
            --print ("Pair ", i, n)
            if i > 1 then
                t[#t+1] = s:sub(1,i-1) -- the good prefix
            end
            s = s:sub(i+2) -- remaining suffix
            n = n - (i + 1)
            i = 1
            --print ("Substr ", i, n)
        else
            i = i + 1
        end
    end
    t[#t+1] = s
    return table.concat(t)
end

function reduc (s)
    local n = s:len()
    while true do
        --print ("Length ", n)
        s = reduc1(s)
        local m = s:len()
        if m == n then
            -- done
            return {m, s}
        else
            n = m
        end
    end
end

-- local res1 = reduc(input)

-- print ("result1 ", res1[2], "length ", res1[1])

--[[
One of the unit types is causing problems; it's preventing the polymer from collapsing as much as it should. Your goal is to figure out which unit type is causing the most problems, remove all instances of it (regardless of polarity), fully react the remaining polymer, and measure its length.

For example, again using the polymer dabAcCaCBAcCcaDA from above:

Removing all A/a units produces dbcCCBcCcD. Fully reacting this polymer produces dbCBcD, which has length 6.
Removing all B/b units produces daAcCaCAcCcaDA. Fully reacting this polymer produces daCAcaDA, which has length 8.
Removing all C/c units produces dabAaBAaDA. Fully reacting this polymer produces daDA, which has length 4.
Removing all D/d units produces abAcCaCBAcCcaA. Fully reacting this polymer produces abCBAc, which has length 6.
In this example, removing all C/c units was best, producing the answer 4.

What is the length of the shortest polymer you can produce by removing all units of exactly one type and fully reacting the result?
]]--

local lb = string.byte("[", 1)
local rb = string.byte("]", 1)

function reduc0 (s, cCpat)
    local t = {}
    for i = 0x41, 0x5A do -- A to Z
        cCpat = string.char(lb, i + 0x20, i, rb) 
        t[#t+1] = s:gsub(cCpat, "")
    end
    return t
end

local testt = reduc0 "dabAcCaCBAcCcaDA"
if "dbcCCBcCcD"     ~= testt[1] then print ("Failed 1 ", testt[1]) end
if "daAcCaCAcCcaDA" ~= testt[2] then print ("Failed 2 ", testt[2]) end
if "dabAaBAaDA"     ~= testt[3] then print ("Failed 3 ", testt[3]) end
if "abAcCaCBAcCcaA" ~= testt[4] then print ("Failed 4 ", testt[4]) end

testt = reduc0(input)
reslt = {}
mini = 0
minl = 10000000

for i = 1, 26 do
    reslt[i] = reduc(testt[i])
    if reslt[i][1] < minl then
        minl = reslt[i][1]
        mini = i
    end
end

print ("result1 for letter", string.char(mini + 0x40), "length ", minl)

print "Done"
