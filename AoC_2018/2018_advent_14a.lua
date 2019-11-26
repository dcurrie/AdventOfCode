

--[[ weird recipes

]]--

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

function adddigits (n)
    if n > 9 then
        adddigits (n // 10)
    end
    scores[#scores+1] = n % 10
end

function puzzstep (n)
    local score = scores[elf1] + scores[elf2]
    adddigits(score)
    elf1 = (elf1 + scores[elf1]) % #scores + 1
    elf2 = (elf2 + scores[elf2]) % #scores + 1
end

for i = 1, 15 do puzzstep() end

for i = 1, #scores do io.write(string.format("%d ", scores[i])) end
print("")

repeat
    puzzstep()
until #scores > 2028

print("After 2018: ")
for i = 2019, 2028 do io.write(string.format("%d ", scores[i])) end
print("")

repeat
    puzzstep()
until #scores > (input + 9)


print("After ", input)
for i = input + 1, input + 10 do io.write(string.format("%d ", scores[i])) end
print("")

print "Done"