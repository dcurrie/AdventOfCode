
--[[ Day 16: Chronal Classification

]]--

local fname = arg[1]
local verbose = (fname == '-v')
if verbose then fname = arg[2] end


local printf = function(s,...)
    return io.write(s:format(...))
end


local regs = {[0] = 0, 0, 0, 0, 0, 0}
local qregs = 6
local pcreg = 0

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

local runins = function (ins)
    local ops = opcode2instr[ins[0]]
    for k,_ in pairs(ops) do
        --if verbose then printf("Registers %d %d %d %d\n", regs[0], regs[1], regs[2], regs[3]) end
        --if verbose then printf("Running %s %d %d %d\n", k, ins[1], ins[2], ins[3]) end
        local ok = _I[k](ins[1], ins[2], ins[3])
        if not ok then
            printf("Bad instruction: %s %d %d %d\n", k, ins[1], ins[2], ins[3])
        end
    end
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

local finduniop = function (unfoundops)
    local op
    for i = 0, 15 do
        local count = 0
        for k,_ in pairs(opcode2instr[i]) do
            if unfoundops[k] then
                op = k
                count = count + 1
            end
        end
        if count == 1 then
            return op, i
        end
    end
    return nil
end

local removedupop = function (op, i)
    for j = 0, 15 do
        if i ~= j then
            dremove(opcode2instr[j], op)
        end
    end
end

local program = {}
local cgenidx = 0

local function part2 ()
    local infile = io.open(fname or "2018_advent_19a.txt")
    local line = infile:read("l")

     while line do
        if line:len() == 0 then 
            -- punt
            line = infile:read("l")
        elseif line:sub(1,1) == '#' then
            local pc = tonumber(line:match("#ip (%d+)"))
            if regok(pc) then
                -- program[#program+1] = {"sepc", pc, 0, 0} -- not an instruction
                pcreg = pc
            else
                print("ERROR #pc is bad:", pc)
            end
            line = infile:read("l")
        else
            local op,i1,i2,i3 = line:match("(%a+) (%d+) (%d+) (%d+)")
            program[cgenidx] = {op, tonumber(i1), tonumber(i2), tonumber(i3)}
            cgenidx = cgenidx + 1
            line = infile:read("l")
        end
    end
    infile:close()

    regs[0] = 1

    local count = 0

    while true do -- count < 100000000
        local pci = regs[pcreg]
        if pci < 0 or pci >= cgenidx then
            break
        end
        local ins = program[pci]
        if verbose then
            -- ip=0 [0, 0, 0, 0, 0, 0] seti 5 0 1 [0, 5, 0, 0, 0, 0]
            printf("ip=%d [%d, %d, %d, %d, %d, %d] %s %d %d %d ",
                pci, regs[0], regs[1], regs[2], regs[3], regs[4], regs[5],
                 ins[1], ins[2], ins[3], ins[4])
        end
        _I[ins[1]](ins[2], ins[3], ins[4])
        if verbose then
            -- ip=0 [0, 0, 0, 0, 0, 0] seti 5 0 1 [0, 5, 0, 0, 0, 0]
            printf("[%d, %d, %d, %d, %d, %d]\n",
                 regs[0], regs[1], regs[2], regs[3], regs[4], regs[5])
        end
        regs[pcreg] = regs[pcreg] + 1
        count = count + 1
    end

    printf("Part2: regs[0] is %d\n", regs[0])

end

part2()

