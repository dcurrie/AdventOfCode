--[[ --- Day 24: Immune System Simulator 20XX ---

]]--

local verbose = ( arg[1] == '-v' or arg[2] == '-v')
local test    = ( arg[1] == '-t' or arg[2] == '-t')

local printf = function(s,...)
    return io.write(s:format(...))
end

local immunesystem
local infection

if test then

--[[
Immune System:
17 units each with 5390 hit points (weak to radiation, bludgeoning) with
 an attack that does 4507 fire damage at initiative 2
989 units each with 1274 hit points (immune to fire; weak to bludgeoning,
 slashing) with an attack that does 25 slashing damage at initiative 3

Infection:
801 units each with 4706 hit points (weak to radiation) with an attack
 that does 116 bludgeoning damage at initiative 1
4485 units each with 2961 hit points (immune to radiation; weak to fire,
 cold) with an attack that does 12 slashing damage at initiative 4
]]--

immunesystem =
{
    {units = 17, hitpoints = 5390, initiative = 2, damage = { 4507, 'fire'}, weakto = {radiation=true, bludgeoning=true}, immuneto = {}},
    {units = 989, hitpoints = 1274, initiative = 3, damage = { 25, 'slashing'}, weakto = {bludgeoning=true, slashing=true}, immuneto = {fire=true}}
}

infection =
{
    {units = 801, hitpoints = 4706, initiative = 1, damage = { 116, 'bludgeoning'}, weakto = {radiation=true}, immuneto = {}},
    {units = 4485, hitpoints = 2961, initiative = 4, damage = { 12, 'slashing'}, weakto = {fire=true, cold=true}, immuneto = {radiation=true}}
}

else

immunesystem =
{
    {units = 7079, hitpoints = 12296, initiative = 14, damage = { 13, 'bludgeoning'}, weakto = {fire=true}},
    {units =  385, hitpoints =  9749, initiative = 16, damage = {196, 'bludgeoning'}, weakto = {cold=true}},
    {units = 2232, hitpoints =  1178, initiative = 20, damage = {  4, 'fire'},        weakto = {cold=true, slashing=true}},
    {units =  917, hitpoints =  2449, initiative = 15, damage = { 25, 'cold'},        weakto = {bludgeoning=true}, immuneto = {fire=true, cold=true}},
    {units = 2657, hitpoints =  2606, initiative = 13, damage = {  9, 'cold'},        weakto = {slashing=true}},
    {units = 2460, hitpoints =  7566, initiative =  8, damage = { 29, 'cold'}},
    {units = 2106, hitpoints =  6223, initiative =  2, damage = { 29, 'bludgeoning'}},
    {units =  110, hitpoints =  7687, initiative = 19, damage = {506, 'slashing'},    weakto = {slashing=true}, immuneto = {radiation=true, fire=true}},
    {units = 7451, hitpoints =  9193, initiative =  6, damage = { 12, 'radiation'},                             immuneto = {cold=true}},
    {units = 1167, hitpoints =  3162, initiative =  9, damage = { 23, 'fire'},        weakto = {fire=true},     immuneto = {bludgeoning=true}}
}

infection =
{
    {units = 2907, hitpoints = 11244, initiative =  7, damage = {  7, 'fire'},               immuneto = {slashing=true}},
    {units = 7338, hitpoints = 12201, initiative =  4, damage = {  3, 'radiation'},          immuneto = {bludgeoning=true, slashing=true, cold=true}},
    {units = 7905, hitpoints = 59276, initiative = 17, damage = { 12, 'cold'},                                immuneto = {fire=true}},
    {units = 1899, hitpoints = 50061, initiative = 10, damage = { 51, 'radiation'},   weakto = {fire=true}},
    {units = 2711, hitpoints = 27602, initiative = 12, damage = { 17, 'cold'}},
    {units =  935, hitpoints = 38240, initiative =  1, damage = { 78, 'bludgeoning'},                         immuneto = {slashing=true}},
    {units = 2783, hitpoints = 17937, initiative = 11, damage = { 12, 'fire'} ,                               immuneto = {cold=true, bludgeoning=true}},
    {units = 8046, hitpoints = 13608, initiative =  5, damage = {  2, 'slashing'},    weakto = {fire=true, bludgeoning=true}},
    {units = 2112, hitpoints = 37597, initiative = 18, damage = { 31, 'slashing'},                            immuneto = {cold=true, slashing=true}},
    {units =  109, hitpoints = 50867, initiative =  3, damage = {886, 'cold'},        weakto = {radiation=true}, immuneto = {slashing=true}}
}

end -- test

local groupsbyinitiative = {}

local function compinitiative (x, y)
    return x.initiative > y.initiative
end

local function prepgroups ()
    local ni = #immunesystem
    for i = 1, ni do
        immunesystem[i].id = i
        immunesystem[i].type = 'Immune System'
        if immunesystem[i].weakto == nil then
            immunesystem[i].weakto = {}
        end
        if immunesystem[i].immuneto == nil then
            immunesystem[i].immuneto = {}
        end
        groupsbyinitiative[i] = immunesystem[i]
    end
    for i = 1, #infection do
        infection[i].id = i
        infection[i].type = 'Infection'
        if infection[i].weakto == nil then
            infection[i].weakto = {}
        end
        if infection[i].immuneto == nil then
            infection[i].immuneto = {}
        end
        groupsbyinitiative[i+ni] = infection[i]
    end
    table.sort(groupsbyinitiative, compinitiative)
end


--[[
Each group also has an effective power: the number of units in that group multiplied by their attack damage. 
Groups never have zero or negative units; instead, the group is removed from combat.
]]--

local function effectivepower (group)
    return group.units * group.damage[1]
end

--[[
The damage an attacking group deals to a defending group depends on the attacking group's attack 
type and the defending group's immunities and weaknesses. By default, an attacking group would 
deal damage equal to its effective power to the defending group. However, if the defending group 
is immune to the attacking group's attack type, the defending group instead takes no damage; 
if the defending group is weak to the attacking group's attack type, the defending group instead 
takes double damage.
]]--

local function calcdamage (attacker, target)
    local attacktype = attacker.damage[2]
    if target.immuneto[attacktype] then
        return 0
    else
        return effectivepower(attacker) * (target.weakto[attacktype] and 2 or 1)
    end
end

--[[
During the target selection phase, each group attempts to choose one target. In decreasing order of effective power, 
groups choose their targets; in a tie, the group with the higher initiative chooses first. The attacking group chooses 
to target the group in the enemy army to which it would deal the most damage (after accounting for weaknesses and 
immunities, but not accounting for whether the defending group has enough units to actually receive all of that damage).

If an attacking group is considering two defending groups to which it would deal equal damage, it chooses to target the 
defending group with the largest effective power; if there is still a tie, it chooses the defending group with the 
highest initiative. If it cannot deal any defending groups damage, it does not choose a target. Defending groups can 
only be chosen as a target by one attacking group.
]]

local function comppower (x, y)
    if effectivepower(x) > effectivepower(y) then
        return true
    elseif effectivepower(x) < effectivepower(y) then
        return false
    else
        return x.initiative > y.initiative
    end
end

local function copyarmy (t)
    local r = {}
    local n = 0
    for i = 1, #t do
        if t[i].units > 0 then
            n = n + 1
            r[n] = t[i]
        end
    end
    return r
end

local function selection (attacker, defender)
    table.sort(attacker, comppower)
    local targets = copyarmy(defender)
    for i = 1, #attacker do
        local maxdamage = 0
        local targetchosen
        local targetchosenx
        attacker[i].target = nil
        for j = 1, #targets do
            local damage = calcdamage(attacker[i], targets[j])
            if damage > maxdamage then
                maxdamage = damage
                targetchosen = targets[j]
                targetchosenx = j
            elseif damage > 0 and damage == maxdamage then
                local epj = effectivepower(targets[j])
                local epx = effectivepower(targetchosen)
                if epj > epx or (epj == epx and targets[j].initiative > targetchosen.initiative) then
                    maxdamage = damage
                    targetchosen = targets[j]
                    targetchosenx = j
                end
            end
            if verbose then 
                printf("%s group %d would deal defending group %d %d damage\n", 
                    attacker == infection and 'Infection' or 'Immune System',
                    attacker[i].id,
                    targets[j].id,
                    damage)
            end
        end
        if maxdamage > 0 then
            attacker[i].target = targetchosen
            table.remove(targets, targetchosenx)
        else
            if verbose then print() end
        end
    end
end

local function selectionphase ()
    selection(infection, immunesystem)
    selection(immunesystem, infection)
end

--[[
During the attacking phase, each group deals damage to the target it selected, if any. Groups 
attack in decreasing order of initiative, regardless of whether they are part of the infection 
or the immune system. (If a group contains no units, it cannot attack.)

The defending group only loses whole units from damage; damage is always dealt in such a way that 
it kills the most units possible, and any remaining damage to a unit that does not immediately 
kill it is ignored. For example, if a defending group contains 10 units with 10 hit points each 
and receives 75 damage, it loses exactly 7 units and is left with 3 units at full health.
]]--

local function attack (group)
    if group.units <= 0 or group.target == nil then
        return
    end
    damage = calcdamage(group, group.target)
    udamage = damage // group.target.hitpoints
    udamage = math.min(udamage, group.target.units)
    group.target.units = group.target.units - udamage
    if verbose then
        printf("%s group %d attacks defending group %d, killing %d units\n", 
            group.type, group.id, group.target.id, udamage)
    end
end

local function attackphase ()
    for i = 1, #groupsbyinitiative do
        attack(groupsbyinitiative[i])
    end
end

local function printstatus()
    printf("Immune System:\n")
    for i = 1, #immunesystem do
        if immunesystem[i].units > 0 then
            printf("Group %d contains %d units\n", immunesystem[i].id, immunesystem[i].units)
        end
    end
    printf("Infection:\n")
    for i = 1, #infection do
        if infection[i].units > 0 then
            printf("Group %d contains %d units\n", infection[i].id, infection[i].units)
        end
    end
    print()
end

-- combat only ends once one army has lost all of its units

local function countunits (army)
    local units = 0
    for i = 1, #army do
        units = units + army[i].units 
    end
    return units
end

local function part2a ()

    local counter = 0

    while true do
        if verbose then printstatus() end
        selectionphase()
        if verbose then print() end
        attackphase()
        if verbose then print() end
        local immu = countunits(immunesystem) 
        local infe = countunits(infection)
        if immu <= 0 or infe <= 0 then
            if verbose then printstatus() end
            printf("Battle over, groups remaining... Immune System %d Infection %d\n", immu, infe)
            return immu - infe
        end
        -- added to bail in deadlocks~!
        counter = counter + 1
        if counter >= 10000 then
            printf("Bailed after %d battles\n", counter)
            return 0
        end
    end
end



local function part2 ()

    prepgroups()

    local origpowers = {}
    for i = 1, #immunesystem do 
        origpowers[immunesystem[i].id] = immunesystem[i].damage[1]
    end
    local origimmuunits = {}
    for i = 1, #immunesystem do 
        origimmuunits[immunesystem[i].id] = immunesystem[i].units
    end
    local originfeunits = {}
    for i = 1, #infection do 
        originfeunits[infection[i].id] = infection[i].units
    end

    local function restoreunits ()
        for i = 1, #immunesystem do 
            immunesystem[i].units = origimmuunits[immunesystem[i].id]
        end
        for i = 1, #infection do 
            infection[i].units = originfeunits[infection[i].id]
        end
    end

    local function boostall (boost)
        for i = 1, #immunesystem do 
            immunesystem[i].damage[1] = origpowers[immunesystem[i].id] + boost
        end
        restoreunits()
    end

    local guesslo =    0 -- a loser
    local guesshi =  1570 // 2
    local score
    local bestscore

    repeat
        guesshi = guesshi * 2
        boostall(guesshi)
        score = part2a()
        printf("Try up: boost %d score %d\n", guesshi, score)
        if score > 0 then
            -- ok
        else
            guesslo = guesshi
        end
    until score > 0

    -- now guesshi always a winner

--[[ used to make original dribble 
    repeat 
        local guess = guesslo + ((guesshi - guesslo) // 2)
        boostall(guess)
        score = part2a()
        printf("Try dn: boost %d score %d\n", guess, score)
        if score > 0 then
            guesshi = guess
            bestscore = score
        else
            guesslo = guess
        end
    until (guesshi - guesslo) < 2
]]--

    bestscore = score

    for i = guesslo + 1, guesshi - 1 do
        boostall(i)
        score = part2a()
        printf("Try ++: boost %d score %d\n", i, score)
        if score > 0 then
            guesshi = i
            break
        end
    end

    print("Part 2", guesshi, score)
end
                        

                        
part2()

-- ok, 2444 worked as an answer, found by looking through the original dribble file
-- binary search doesn't work, the scores are not monotonic by boost
-- so re-did code for linear search, but got stuck in deadlock battle w/ boost 54!
-- added "timeout" in part2a, and finished quickly (at 55, score 2444)


print "Done"
