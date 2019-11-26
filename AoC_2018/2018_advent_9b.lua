

--[[
First, the marble numbered 0 is placed in the circle. At this point, while it contains only a 
single marble, it is still a circle: the marble is both clockwise from itself and 
counter-clockwise from itself. This marble is designated the current marble.

Then, each Elf takes a turn placing the lowest-numbered remaining marble into the circle between 
the marbles that are 1 and 2 marbles clockwise of the current marble. (When the circle is large 
enough, this means that there is one marble between the marble that was just placed and the 
current marble.) The marble that was just placed then becomes the current marble.

However, if the marble that is about to be placed has a number which is a multiple of 23, 
something entirely different happens. First, the current player keeps the marble they would have 
placed, adding it to their score. In addition, the marble 7 marbles counter-clockwise from the 
current marble is removed from the circle and also added to the current player's score. The 
marble located immediately clockwise of the marble that was removed becomes the new current 
marble.
]]--

function cins (circ, valu)
    local i = {prv = circ.prv, nxt = circ, val = valu}
    circ.prv.nxt = i
    circ.prv = i
    return i -- new circle
end

function crem (circ)
    local n = circ.nxt
    local p = circ.prv
    p.nxt = n
    n.prv = p
    return n
end

function cprv (circ, n)
    local p = circ
    for i = 1, n do p = p.prv end
    return p
end

function cnxt (circ, n)
    local p = circ
    for i = 1, n do p = p.nxt end
    return p
end

local verbose = false

function cprt (circ)
    local p = circ
    repeat
        io.write(string.format("%d ", p.val))
        p = p.nxt
    until p.val == circ.val
--    for i = 1, 25 do
--        io.write(string.format("(%d %d %d) ", p.prv.val, p.nxt.val, p.val))
--        p = p.nxt
--    end
    print ";"
end

function game (str, mult)
    local current = {}
    current.prv = current
    current.nxt = current
    current.val = 0

    local splayers, slast = str:match("(%d+) players; last marble is worth (%d+) points")

    local players = tonumber(splayers)
    local last = tonumber(slast) * (mult or 1)

    print ("Read ", players, "players, last marble ", last)

    local scores = {}
    local player = 1

    for i = 1, players do
        scores[i] = 0
    end

    for i = 1, last do
        if i % 23 == 0 then
            scores[player] = scores[player] + i
            current = cprv(current, 7)
            scores[player] = scores[player] + current.val
            current = crem(current)
        else
            current = cnxt(current, 2)
            current = cins(current, i)
        end
        player = (player % players) + 1

        if verbose then cprt(current) end
    end

    local highscore = 0
    for i = 1, players do
        if scores[i] > highscore then highscore = scores[i] end
    end
    return highscore
end

--[[ examples:
9 players; last marble is worth 25 points: high score is 32
10 players; last marble is worth 1618 points: high score is 8317
13 players; last marble is worth 7999 points: high score is 146373
17 players; last marble is worth 1104 points: high score is 2764
21 players; last marble is worth 6111 points: high score is 54718
30 players; last marble is worth 5807 points: high score is 37305
]]--
--[[ ]]
verbose = true
print ("Ex 0: 32 ", game("9 players; last marble is worth 25 points"))
verbose = false
print ("Ex 1: 8317 ", game("10 players; last marble is worth 1618 points"))
print ("Ex 2: 146373 ", game("13 players; last marble is worth 7999 points"))
print ("Ex 3: 2764 ", game("17 players; last marble is worth 1104 points"))
print ("Ex 4: 54718 ", game("21 players; last marble is worth 6111 points"))
print ("Ex 5: 37305 ", game("30 players; last marble is worth 5807 points"))
--]]--

print ("Part 1, high score is ", game("452 players; last marble is worth 71250 points", 1))

print ("Part 2, high score is ", game("452 players; last marble is worth 71250 points", 100))


print ("Done")

