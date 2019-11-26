
--[[ --- Day 21: Chronal Conversion ---

]]--

local fname = arg[1]
local verbose = (fname == '-v')
if verbose then fname = arg[2] end
local count = fname:sub(1,2)
if count == '-c' then
    count = tonumber(fname:sub(3))
    fname = arg[3]
end

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

local function part1 ()
    local infile = io.open(fname or "2018_advent_21a.txt")
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

    regs[0] = 11521639

    local last4 = 0

    local count = count or 100000000

    local seen = {[9566170]=true}

    for i = 1, count do
        local pci = regs[pcreg]
        if pci < 0 or pci >= cgenidx then
            printf("Part1: regs[0] is %d after %d instructions\n", regs[0], i-1)
            break
        end
        if verbose and (pci == 30 or (pci >= 6 and pci <= 13)) then
            printf("[%8d, %8d, %8d, %8d, %8d, %8d]\n",
                  regs[0], regs[1], regs[2], regs[3], regs[4], regs[5])
            if pci == 30 then print() end
        end
        if (pci == 28) then
            --printf("[%8d, %8d, %8d, %8d, %8d, %8d]\n",
            --      regs[0], regs[1], regs[2], regs[3], regs[4], regs[5])
            --[[
            if regs[4] == 9566170 and last4 ~=0 then                       --- Groan... if only I'd kept a table, as I do in sim() below, this would have worked
                printf("last r4 is %8d\n", last4)
                break
            else
                last4 = regs[4]
            end
            ]]--
            if last4 ~=0 and seen[regs[4]] then
                printf("Part 2: last r4 is %8d\n", last4)
                break
            else
                last4 = regs[4]
                seen[last4] = true
            end
         end
        local ins = program[pci]
        if verbose then
            -- ip=0 [0, 0, 0, 0, 0, 0] seti 5 0 1 [0, 5, 0, 0, 0, 0]
            printf("ip=%3d [%8d, %8d, %8d, %8d, %8d, %8d] %5s %8d %8d %8d ",
                pci, regs[0], regs[1], regs[2], regs[3], regs[4], regs[5],
                 ins[1], ins[2], ins[3], ins[4])
        end
        _I[ins[1]](ins[2], ins[3], ins[4])
        if verbose then
            -- ip=0 [0, 0, 0, 0, 0, 0] seti 5 0 1 [0, 5, 0, 0, 0, 0]
            printf("[%8d, %8d, %8d, %8d, %8d, %8d]\n",
                 regs[0], regs[1], regs[2], regs[3], regs[4], regs[5])
        end
        regs[pcreg] = regs[pcreg] + 1
    end
end

part1()

function sim6_12()
    r3 = r4 | 65536
    r4 = 4332021
    r2 = r3 & 255
    r4 = r4 + r2
    r4 = r4 & 16777215
    r4 = r4 * 65899
    r4 = r4 & 16777215
end

function sim8_12()
    r2 = r3 & 255
    r4 = r4 + r2
    r4 = r4 & 16777215
    r4 = r4 * 65899
    r4 = r4 & 16777215
end

function sim1 (count)
    r3 = 1
    r4 = 9566170
    sim6_12()
    for i = 1, count do
        r3 = r3 // 256
        printf("Step r3: %8d r4: %8d\n", r3, r4)
        if r3 == 0 then
            if 9566170 == r4 then
                break
            else
                sim6_12()
            end
        else
            sim8_12()
        end
    end
end

function sim2 (count)
    lastck = 9566170
    r3 = 1
    r4 = 9566170
    sim6_12()
    for i = 1, count do
        r3 = r3 // 256
        -- printf("Step r3: %8d r4: %8d\n", r3, r4)
        if r3 == 0 then
            if 9566170 == r4 then
                printf("Part 2: %d\n", lastck)
                break
            else
                lastck = r4
                sim6_12()
            end
        else
            sim8_12()
        end
    end
end

function sim (count)
    lastck = 9566170
    seen = {[9566170]=t}
    r3 = 1
    r4 = 9566170
    sim6_12()
    for i = 1, count do
        r3 = r3 // 256
        -- printf("Step r3: %8d r4: %8d\n", r3, r4)
        if r3 == 0 then
            if seen[r4] then
                printf("Part 2: %d\n", lastck)
                break
            else
                lastck = r4
                seen[r4] = true
                sim6_12()
            end
        else
            sim8_12()
        end
    end
end


sim(1000000000)

-- Part 2: 13192622       ################################ Winner!


--[[
#ip 5
00 seti 123 0 4
01 bani 4 456 4
02 eqri 4 72 4
03 addr 4 5 5
04 seti 0 0 5
05 seti 0 0 4
06 bori 4 65536 3       <<<<<< r[3] = r[4] | 65536
07 seti 4332021 4 4     <<<<<< r[4] = 4332021
08 bani 3 255 2         <<<<<< r[2] = r[3] & 255
09 addr 4 2 4           <<<<<< r[4] += r[2]
10 bani 4 16777215 4    <<<<<< r[4] &= 16777215
11 muli 4 65899 4       <<<<<< r[4] *= 65899
12 bani 4 16777215 4    <<<<<< r[4] &= 16777215
13 gtir 256 3 2         <<<<<< r[2] = r[3] > 256 
14 addr 2 5 5           <<<<<< if (r[3] > 256) skip to 16... to 28
15 addi 5 1 5           <<<<<< skip to 17
16 seti 27 5 5          <<<<<< goto 28
17 seti 0 2 2           <<<<<< r[2] = 0
18 addi 2 1 1           <<<<<< r[1] = r[1] + r[2]
19 muli 1 256 1         <<<<<< r[1] *= 256
20 gtrr 1 3 1           <<<<<< r[1] = (r[1] > r[3])
21 addr 1 5 5           <<<<<< if (r[1] > r[3]) skip to 23... to 26
22 addi 5 1 5           <<<<<< skip to 24
23 seti 25 2 5          <<<<<<< goto 26
24 addi 2 1 2           <<<<<<< r[2] += 1
25 seti 17 3 5          <<<<<<< goto 18
26 setr 2 7 3           <<<<<<< r[3] = r[2]       <<<<<< 45007 ( * 256 = 11521792)
27 seti 7 1 5           <<<<<<< goto 8
28 eqrr 4 0 2           <<<<<<< r2 = (r[4] == r[0])  !!!!!!!
29 addr 2 5 5           <<<<<<< DONE
30 seti 5 6 5           <<<<<<< goto 6



r4 <- ?  (9566170)
r3 = r4 | 65536
r4 = 4332021
r2 = r3 & 255 == prev_r4 & 255
r4 = r2 + r4
r4 &= 16777215
r4 *= 65899
r4 &= 16777215

six2twelve
r4 = (((r4 & 255) + 4332021) * 65899) & 16777215

eight2twelve
r3 = r4 | 65536

r4 = (((r4 // 256) & 255) * 65899) & 16777215


if r3 > 256 then six2twelve else if r0 == r4 then done else eight2twelve end end


ip= 20 [11521639,      256,        0,    65536, 11521639,       20]  gtrr        1        3        1 [11521639,        0,        0,    65536, 11521639,       20]
ip= 21 [11521639,        0,        0,    65536, 11521639,       21]  addr        1        5        5 [11521639,        0,        0,    65536, 11521639,       21]
ip= 22 [11521639,        0,        0,    65536, 11521639,       22]  addi        5        1        5 [11521639,        0,        0,    65536, 11521639,       23]
ip= 24 [11521639,        0,        0,    65536, 11521639,       24]  addi        2        1        2 [11521639,        0,        1,    65536, 11521639,       24]
ip= 25 [11521639,        0,        1,    65536, 11521639,       25]  seti       17        3        5 [11521639,        0,        1,    65536, 11521639,       17]
ip= 18 [11521639,        0,        1,    65536, 11521639,       18]  addi        2        1        1 [11521639,        2,        1,    65536, 11521639,       18]
ip= 19 [11521639,        2,        1,    65536, 11521639,       19]  muli        1      256        1 [11521639,      512,        1,    65536, 11521639,       19]
ip= 20 [11521639,      512,        1,    65536, 11521639,       20]  gtrr        1        3        1 [11521639,        0,        1,    65536, 11521639,       20]
ip= 21 [11521639,        0,        1,    65536, 11521639,       21]  addr        1        5        5 [11521639,        0,        1,    65536, 11521639,       21]
ip= 22 [11521639,        0,        1,    65536, 11521639,       22]  addi        5        1        5 [11521639,        0,        1,    65536, 11521639,       23]
ip= 24 [11521639,        0,        1,    65536, 11521639,       24]  addi        2        1        2 [11521639,        0,        2,    65536, 11521639,       24]
ip= 25 [11521639,        0,        2,    65536, 11521639,       25]  seti       17        3        5 [11521639,        0,        2,    65536, 11521639,       17]
ip= 18 [11521639,        0,        2,    65536, 11521639,       18]  addi        2        1        1 [11521639,        3,        2,    65536, 11521639,       18]
ip= 19 [11521639,        3,        2,    65536, 11521639,       19]  muli        1      256        1 [11521639,      768,        2,    65536, 11521639,       19]
ip= 20 [11521639,      768,        2,    65536, 11521639,       20]  gtrr        1        3        1 [11521639,        0,        2,    65536, 11521639,       20]

]]--

