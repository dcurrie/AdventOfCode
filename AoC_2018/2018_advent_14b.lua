
--[[ weird recipes

]]--

-- input = 51589 --> 9
-- input = 01245 --> 6 s.b. 5 due to leading 0
-- input = 92510 --> 18
-- input = 59414 --> 2018

input = 190221

scores = {3, 7}

elf1 = 1
elf2 = 2

--[[
To create new recipes, the two Elves combine their current recipes. This creates new recipes 
from the digits of the sum of the current recipes' scores. With the current recipes' scores of 
3 and 7, their sum is 10, and so two new recipes would be created: the first with score 1 and 
the second with score 0. If the current recipes' scores were 2 and 3, the sum, 5, would only 
create one recipe (with a score of 5) with its single digit.

]]

winstate = 1
wigits = {}

function addwigits (n)
    if n > 9 then
        addwigits (n // 10)
    end
    wigits[#wigits+1] = n % 10
end

addwigits(input)

print ("Win state:")
for i = 1, #wigits do io.write(string.format("%d ", wigits[i])) end
print("")

local done = false

function addscore (n)
    scores[#scores+1] = n
    if wigits[winstate] == n then
        winstate = winstate + 1
    else
        winstate = 1
        if wigits[1] == n then
            winstate = 2
        end
    end
    if winstate == #wigits+1 then
        print("After ", #scores, #scores - #wigits)
        for i = #scores - #wigits, #scores do io.write(string.format("%d ", scores[i])) end
        print("")
        done = true
    end
end

function adddigits (n)
    if n > 9 then
        adddigits (n // 10)
    end
    addscore(n % 10)
end

function puzzstep ()
    local score = scores[elf1] + scores[elf2]
    adddigits(score)
    elf1 = (elf1 + scores[elf1]) % #scores + 1
    elf2 = (elf2 + scores[elf2]) % #scores + 1
end

repeat puzzstep()
until done


--for i = 20268576, 20268576 + 6  do io.write(string.format("%d ", scores[i])) end
--print("")

print "Done"
