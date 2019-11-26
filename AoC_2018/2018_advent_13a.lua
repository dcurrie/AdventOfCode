

--[[ vehicles

]]--

local map = {}
local carts = {}

local EW = string.byte("-", 1)
local NS = string.byte("|", 1)
local XX = string.byte("+", 1)
local NW = string.byte("\\", 1)  -- also SE, ES, WN
local NE = string.byte("/", 1)   -- also SW, EN, WS

local MN = string.byte("^", 1)
local MS = string.byte("v", 1)
local MW = string.byte("<", 1)
local ME = string.byte(">", 1)

local N = 1
local E = 2
local S = 3
local W = 4

local infile = io.open("2018_advent_13a.txt")
local line = infile:read("l")
local xdim = line:len()
local ydim = 0

while line do
    if line:len() ~= xdim then 
        -- punt
        print("Bad line ", ydim)
    else
        ydim = ydim + 1 -- note that our x/y coordinates are 1-based, problem statement is 0-based
        local row = {}
        for i = 1, xdim do
            local c = line:byte(i)
            if c == EW or c == NS or c == NW or c == NE or c == XX then
                row[i] = c
            elseif c == MN or c == MS then
                local m = N
                if c == MS then m = S end
                row[i] = NS
                local id = #carts+1
                carts[id] = {i=id, x=i, y=ydim, m=m, t=0} -- 0 is number of turns so far
            elseif c == MW or c == ME then
                local m = W
                if c == ME then m = E end
                row[i] = EW
                local id = #carts+1
                carts[id] = {i=id, x=i, y=ydim, m=m, t=0} -- 0 is number of turns so far
            elseif c == 0x20 then
                -- ok
            else
                print("oops, see: ", string.char(c))
            end
        end
        map[ydim] = row
    end
    line = infile:read("l")
end
infile:close()

print ("Read ", xdim, ydim, " map, and ", #carts, " carts")

--[[
Each time a cart has the option to turn (by arriving at any intersection), it turns left the 
first time, goes straight the second time, turns right the third time, and then repeats those 
directions starting again with left the fourth time, straight the fifth time, and so on. This 
process is independent of the particular intersection at which the cart has arrived - that is, 
the cart has no per-intersection memory.

Carts all move at the same speed; they take turns moving a single step at a time. They do this 
based on their current location: carts on the top row move first (acting from left to right), 
then carts on the second row move (again from left to right), then carts on the third row, and 
so on. Once each cart has moved one step, the process repeats; each of these loops is called a 
tick.

]]

-- convert turns so far mod 3 & direction into next direction
--              L  S  R
--              0  1  2  
local turn = {{ W, N, E }, -- N
              { N, E, S }, -- E
              { E, S, W }, -- S
              { S, W, N }} -- W

-- convert curve and dirrection to new direction
-- NW = string.byte("\\", 1)  -- also SE, ES, WN
--              N  E  S  W
local curvNW = {W, S, E, N}

-- NE = string.byte("/", 1)   -- also SW, EN, WS
--              N  E  S  W
local curvNE = {E, N, W, S}

local posn = {}

function cart2idx (cart) return (cart.x * (ydim + 1)) + cart.y end

for i = 1, #carts do posn[cart2idx(carts[i])] = carts[i] end

function move (cart)
        if cart.m == W then 
            cart.x = cart.x - 1
        elseif cart.m == E then 
            cart.x = cart.x + 1
        elseif cart.m == N then 
            cart.y = cart.y - 1
        elseif cart.m == S then 
            cart.y = cart.y + 1
        else
            print("Cart err NESW", cart.i, cart.m)
        end
end

function cartlt (x, y)
    return (x.y < y.y) or ((x.y == y.y) and (x.x < y.x))
end

local collision = false

local badcarts = {}
local qbadcarts = 0

function remcart (cart)
    for i = 1, #carts do
        if cart == carts[i] then
            table.remove(carts, i)
            break
        end
    end
end

while (qbadcarts + 1) < #carts do
    for i = 1, #carts do
        local cart = carts[i]
        if badcarts[cart] then 
            -- continue -- needed for part 2
        else
            local c = map[cart.y][cart.x]
            posn[cart2idx(cart)] = nil -- remove from current posn
            -- find new posn
            if     c == EW then
                if cart.m == W then 
                    cart.x = cart.x - 1
                elseif cart.m == E then 
                    cart.x = cart.x + 1
                else
                    print("Cart err EW", cart.i, string.char(c), cart.m)
                end
            elseif c == NS then
                if cart.m == N then 
                    cart.y = cart.y - 1
                elseif cart.m == S then 
                    cart.y = cart.y + 1
                else
                    print("Cart err NS", cart.i, string.char(c), cart.m)
                end
            elseif c == NW then
                cart.m = curvNW[cart.m]
                move(cart)
            elseif c == NE then
                cart.m = curvNE[cart.m]
                move(cart)
            elseif c == XX then
                cart.m = turn[cart.m][(cart.t % 3) + 1]
                move(cart)
                cart.t = cart.t + 1
            end
            if posn[cart2idx(cart)] then
                -- collision
                print("Collision", cart.i, posn[cart2idx(cart)].i, cart.x, cart.y)
                if not collision then
                    print ("Part1 ", cart.x - 1, cart.y - 1)
                    collision = true
                end
                -- remove two carts
                badcarts[cart] = true
                badcarts[posn[cart2idx(cart)]] = true
                posn[cart2idx(cart)] = nil
                qbadcarts = qbadcarts + 2

                -- break -- fought this bug for half an hour; was useful in part 1; breaks (!) part 2

            else
                posn[cart2idx(cart)] = cart
            end
        end
    end
--    for i = 1, #badcarts do
--        remcart(badcarts[i])
--    end
    table.sort(carts, cartlt)
end

for i = 1, #carts do
    local cart = carts[i]
    if not badcarts[cart] then
        print ("Part2 cat ID ", cart.i, "at ", cart.x - 1, cart.y - 1)
        break
    end
end

print "Done"
