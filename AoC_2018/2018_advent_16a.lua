
--[[ Day 16: Chronal Classification

]]--

local fname = arg[1]
local verbose = (fname == '-v')


local printf = function(s,...)
    return io.write(s:format(...))
end


local regs = {[0] = 0, 0, 0, 0}
local qregs = 4

local regok = function (n) return n >= 0 and n < qregs end

local _I = {} -- instruction table

--[[
addr (add register) stores into register C the result of adding register A and register B.
]]--

_I.addr = function (A, B, C)
    if regok(A) and regok(B) and regok(C) then
        regs[C] = regs[A] + regs[B]
        return true
    else
        return false
    end
end

--[[
addi (add immediate) stores into register C the result of adding register A and value B.
]]--

_I.addi = function (A, B, C)
    if regok(A) and regok(C) then
        regs[C] = regs[A] + B
        return true
    else
        return false
    end
end

--[[
mulr (multiply register) stores into register C the result of multiplying register A and register B.
]]--

_I.mulr = function (A, B, C)
    if regok(A) and regok(B) and regok(C) then
        regs[C] = regs[A] * regs[B]
        return true
    else
        return false
    end
end

--[[
muli (multiply immediate) stores into register C the result of multiplying register A and value B.
]]--

_I.muli = function (A, B, C)
    if regok(A) and regok(C) then
        regs[C] = regs[A] * B
        return true
    else
        return false
    end
end

--[[
banr (bitwise AND register) stores into register C the result of the bitwise AND of register A and register B.
]]--

_I.banr = function (A, B, C)
    if regok(A) and regok(B) and regok(C) then
        regs[C] = regs[A] & regs[B]
        return true
    else
        return false
    end
end

--[[
bani (bitwise AND immediate) stores into register C the result of the bitwise AND of register A and value B.
]]--

_I.bani = function (A, B, C)
    if regok(A) and regok(C) then
        regs[C] = regs[A] & B
        return true
    else
        return false
    end
end

--[[
borr (bitwise OR register) stores into register C the result of the bitwise OR of register A and register B.
]]--

_I.borr = function (A, B, C)
    if regok(A) and regok(B) and regok(C) then
        regs[C] = regs[A] | regs[B]
        return true
    else
        return false
    end
end

--[[
bori (bitwise OR immediate) stores into register C the result of the bitwise OR of register A and value B.
]]--

_I.bori = function (A, B, C)
    if regok(A) and regok(C) then
        regs[C] = regs[A] | B
        return true
    else
        return false
    end
end

--[[
setr (set register) copies the contents of register A into register C. (Input B is ignored.)
]]--

_I.setr = function (A, B, C)
    if regok(A) and regok(C) then
        regs[C] = regs[A]
        return true
    else
        return false
    end
end

--[[
seti (set immediate) stores value A into register C. (Input B is ignored.)
]]--

_I.seti = function (A, B, C)
    if regok(C) then
        regs[C] = A
        return true
    else
        return false
    end
end

--[[
gtir (greater-than immediate/register) sets register C to 1 if value A is greater than register B. Otherwise, register C is set to 0.
]]--

_I.gtir = function (A, B, C)
    if regok(B) and regok(C) then
        if A > regs[B] then
            regs[C] = 1
        else 
            regs[C] = 0
        end
        return true
    else
        return false
    end
end

--[[
gtri (greater-than register/immediate) sets register C to 1 if register A is greater than value B. Otherwise, register C is set to 0.
]]--

_I.gtri = function (A, B, C)
    if regok(A) and regok(C) then
        if regs[A] > B then
            regs[C] = 1
        else 
            regs[C] = 0
        end
        return true
    else
        return false
    end
end

--[[
gtrr (greater-than register/register) sets register C to 1 if register A is greater than register B. Otherwise, register C is set to 0.
]]--

_I.gtrr = function (A, B, C)
    if regok(A) and regok(B) and regok(C) then
        if regs[A] > regs[B] then
            regs[C] = 1
        else 
            regs[C] = 0
        end
        return true
    else
        return false
    end
end

--[[
eqir (equal immediate/register) sets register C to 1 if value A is equal to register B. Otherwise, register C is set to 0.
]]--

_I.eqir = function (A, B, C)
    if regok(B) and regok(C) then
        if A == regs[B] then
            regs[C] = 1
        else 
            regs[C] = 0
        end
        return true
    else
        return false
    end
end

--[[
eqri (equal register/immediate) sets register C to 1 if register A is equal to value B. Otherwise, register C is set to 0.
]]--

_I.eqri = function (A, B, C)
    if regok(A) and regok(C) then
        if regs[A] == B then
            regs[C] = 1
        else 
            regs[C] = 0
        end
        return true
    else
        return false
    end
end

--[[
eqrr (equal register/register) sets register C to 1 if register A is equal to register B. Otherwise, register C is set to 0.
]]--

_I.eqrr = function (A, B, C)
    if regok(A) and regok(B) and regok(C) then
        if regs[A] == regs[B] then
            regs[C] = 1
        else 
            regs[C] = 0
        end
        return true
    else
        return false
    end
end


-- destructive sets

local dunion = function (T, S)
    for k,_ in pairs(S) do
        T[k] = true
    end
    return T
end

local dremove = function (T, v)
    T[v] = nil
    return T
end

local setsize = function (S)
    local n = 0
    for _,_ in pairs(S) do
        n = n + 1
    end
    return n
end

-- setup sets

local opcode2instr = {}

local printo2i = function ()
    for i = 0, 15 do
        printf("%2d (%2d)", i, setsize(opcode2instr[i]))
        for k,_ in pairs(opcode2instr[i]) do
            printf(" %s", k)
        end
        printf("\n")
    end
end

local setupsets = function ()
    for i = 0, 15 do
        opcode2instr[i] = dunion({},_I)
    end
    if verbose then
        printo2i()
        if opcode2instr[1] == opcode2instr[2] then print "Error" end
    end
end

-- 

local rejects = 0

local tryins = function (rin, ins, rou)
    local bad = {}
    local ops = opcode2instr[ins[0]]
    for k,_ in pairs(ops) do
        for i = 0, 3 do regs[i] = rin[i] end
        --if verbose then printf("Registers %d %d %d %d\n", regs[0], regs[1], regs[2], regs[3]) end
        --if verbose then printf("Trying %s %d %d %d\n", k, ins[1], ins[2], ins[3]) end
        local ok = _I[k](ins[1], ins[2], ins[3])
        if ok then
            for i = 0, 3 do
                if regs[i] ~= rou[i] then
                    ok = false
                    break
                end
            end
        end
        if not ok then
            bad[#bad+1] = k
            rejects = rejects + 1
        end
    end
    for i = 1, #bad do dremove(ops, bad[i]) end
end

local trysam = function (rin, ins, rou)
    local qbad = 0
    local ops = opcode2instr[ins[0]]
    for k,_ in pairs(ops) do
        for i = 0, 3 do regs[i] = rin[i] end
        --if verbose then printf("Registers %d %d %d %d\n", regs[0], regs[1], regs[2], regs[3]) end
        --if verbose then printf("Trying %s %d %d %d\n", k, ins[1], ins[2], ins[3]) end
        local ok = _I[k](ins[1], ins[2], ins[3])
        if ok then
            for i = 0, 3 do
                if regs[i] ~= rou[i] then
                    ok = false
                    break
                end
            end
        end
        if not ok then
            qbad = qbad + 1
            rejects = rejects + 1
        end
    end
    return 16 - qbad
end


local function part1_mistake () -- this does: what opcodes work for all samples
    local infile = io.open("2018_advent_16a.txt")
    local line = infile:read("l")

    setupsets()

    local rin = {}
    local ins = {}
    local rou = {}

    local tried = {}
    rejects = 0

    while line do
        if line:len() == 0 then 
            -- punt
            line = infile:read("l")
        else
            local i0,i1,i2,i3 = line:match("Before: %[(%d+), (%d+), (%d+), (%d+)%]") -- Before: [3, 2, 3, 3]
            rin[0] = tonumber(i0)
            rin[1] = tonumber(i1)
            rin[2] = tonumber(i2)
            rin[3] = tonumber(i3)
            line = infile:read("l")
            local i0,i1,i2,i3 = line:match("(%d+) (%d+) (%d+) (%d+)")              -- 14 0 2 3
            ins[0] = tonumber(i0)
            ins[1] = tonumber(i1)
            ins[2] = tonumber(i2)
            ins[3] = tonumber(i3)
            line = infile:read("l")
            local i0,i1,i2,i3 = line:match("After:  %[(%d+), (%d+), (%d+), (%d+)%]")  -- After: [3, 2, 3, 3]
            rou[0] = tonumber(i0)
            rou[1] = tonumber(i1)
            rou[2] = tonumber(i2)
            rou[3] = tonumber(i3)
            line = infile:read("l")

            tryins(rin, ins, rou)
            tried[ins[0]] = (tried[ins[0]] or 0) + 1
        end
    end
    infile:close()

    printo2i()

    local result = 0
    for i = 0, 15 do
        local count = 0
        for k,_ in pairs(opcode2instr[i]) do
            count = count + 1
        end
        if count >= 3 then result = result + 1 end
    end

    local totaltries = 0
    if verbose then
        printf("Tries:")
        for i = 0, 15 do
            printf(" %d", tried[i])
            totaltries = totaltries + tried[i]
        end
        printf(" (%d), %d rejects\n", totaltries, rejects)
    end

    printf("Part1: %d ops have more than 2 possibilites\n", result)
end

-- the real question is "how many samples in your puzzle input behave like three or more opcodes?"

local function part1 () -- this does: what opcodes work for all samples
    local infile = io.open("2018_advent_16a.txt")
    local line = infile:read("l")

    setupsets()

    local rin = {}
    local ins = {}
    local rou = {}

    local result = 0
    local tried = {}
    rejects = 0

    while line do
        if line:len() == 0 then 
            -- punt
            line = infile:read("l")
        else
            local i0,i1,i2,i3 = line:match("Before: %[(%d+), (%d+), (%d+), (%d+)%]") -- Before: [3, 2, 3, 3]
            rin[0] = tonumber(i0)
            rin[1] = tonumber(i1)
            rin[2] = tonumber(i2)
            rin[3] = tonumber(i3)
            line = infile:read("l")
            local i0,i1,i2,i3 = line:match("(%d+) (%d+) (%d+) (%d+)")              -- 14 0 2 3
            ins[0] = tonumber(i0)
            ins[1] = tonumber(i1)
            ins[2] = tonumber(i2)
            ins[3] = tonumber(i3)
            line = infile:read("l")
            local i0,i1,i2,i3 = line:match("After:  %[(%d+), (%d+), (%d+), (%d+)%]")  -- After: [3, 2, 3, 3]
            rou[0] = tonumber(i0)
            rou[1] = tonumber(i1)
            rou[2] = tonumber(i2)
            rou[3] = tonumber(i3)
            line = infile:read("l")

            local candidates = trysam(rin, ins, rou)
            if candidates >= 3 then
                result = result + 1
            end

            tried[ins[0]] = (tried[ins[0]] or 0) + 1
        end
    end
    infile:close()

    printf("Part1: %d samples have more than 3 possibilites\n", result)
end

part1()



