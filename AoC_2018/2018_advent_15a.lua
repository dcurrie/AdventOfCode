
--[[ Beverage Bandits

]]--

local printf = function(s,...)
    return io.write(s:format(...))
end

-- arena[y][x] = '#' when there's a wall
--               '.' when it's open
--               'E' for elf
--               'G' for gremlin
local arena = {}

local elves = {}
local grems = {}


local fname = arg[1]
local verbose = (fname == '-v')
if verbose then fname = arg[2] end

local infile = io.open(fname or "2018_advent_15a.txt")

-- local infile = io.open("2018_advent_15at2.txt")
-- local verbose = true

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
            local c = line:sub(i,i)
            if c == '#' or c == '.' then
                row[i] = c
            elseif c == 'G' then
                row[i] = c
                grems[#grems+1] = {i = #grems+1, c=c, t='E', ts=elves, x = i, y = ydim, pwr=3, hit=200}
            elseif c == 'E' then
                row[i] = c
                elves[#elves+1] = {i = #elves+1, c=c, t='G', ts=grems, x = i, y = ydim, pwr=3, hit=200}
            else
                print("oops, see: ", string.char(c))
            end
        end
        arena[ydim] = row
    end
    line = infile:read("l")
end
infile:close()

print ("Read", xdim, ydim, " arena,", #elves, "elves", #grems, "gremlins")

function pos2hash (x, y) return ((y - 1) * xdim) + (x - 1) end

function hash2pos (h) return (h % xdim) + 1, (h // xdim) + 1 end

-- min heap
-- http://lua-users.org/lists/lua-l/2007-07/msg00482.html
-- modifed with decr() added and new indxs to support that

local function push (h, k, v)
  assert(v ~= nil, "cannot push nil")
  local t = h.nodes
  local i = h.indxs
  local h = h.heap
  local n = #h + 1 -- node position in heap array (leaf)
  local p = (n - n % 2) / 2 -- parent position in heap array
  h[n] = k -- insert at a leaf
  t[k] = v
  i[k] = n
  while n > 1 and t[h[p]] > v do -- climb heap?
    h[p], h[n] = h[n], h[p]
    i[h[p]] = p
    i[h[n]] = n
    n = p
    p = (n - n % 2) / 2
  end
end

local function decr (mh, k, v)
  assert(v ~= nil, "cannot decr nil")
  local t = mh.nodes
  local i = mh.indxs
  local h = mh.heap
  local n = i[k] -- node position in heap array
  if n then
     t[k] = v
     local p = (n - n % 2) / 2 -- parent position in heap array
      while n > 1 and t[h[p]] > v do -- climb heap?
        h[p], h[n] = h[n], h[p]
        i[h[p]] = p
        i[h[n]] = n
        n = p
        p = (n - n % 2) / 2
      end
  else
      mh:push(k, v)
  end 
end

local function pop (h)
  local t = h.nodes
  local i = h.indxs
  local h = h.heap
  local s = #h
  assert(s > 0, "cannot pop from empty heap")
  local e = h[1] -- min (heap root)
  local r = t[e]
  local v = t[h[s]]
  h[1] = h[s] -- move leaf to root
  i[h[1]] = 1
  h[s] = nil -- remove leaf
  t[e] = nil
  i[e] = nil
  s = s - 1
  local n = 1 -- node position in heap array
  local p = 2 * n -- left sibling position
  if s > p and t[h[p]] > t[h[p + 1]] then
    p = 2 * n + 1 -- right sibling position
  end
  while s >= p and t[h[p]] < v do -- descend heap?
    h[p], h[n] = h[n], h[p]
    i[h[p]] = p
    i[h[n]] = n
    n = p
    p = 2 * n
    if s > p and t[h[p]] > t[h[p + 1]] then
      p = 2 * n + 1
    end
  end
  return e, r
end

local function isempty (h) return h.heap[1] == nil end

function newheap ()
  return setmetatable({heap = {}, nodes = {}, indxs = {}},
      {__index = {push=push, pop=pop, decr=decr, isempty=isempty}})
end

-- test heap
local h = newheap()
--for i=1,20 do h:push(i, math.random()) end
--while not h:isempty() do print(h:pop()) end
for i=1,2000 do h:push(i, math.random()) end
local n = 0
for i=1,2000 do local k,v = h:pop(); if v < n then print "Error in heap" end n = v end
for i=1,2000 do h:push(i, math.random()) end
for i=1,1000 do local i = math.floor(math.random() * 2000) + 1; h:decr(i, h.nodes[i] / 2.0) end
local n = 0
for i=1,2000 do local k,v = h:pop(); if v < n then print "Error in heap" end n = v end

--[[ https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
1  function Dijkstra(Graph, source):
2      dist[source] ← 0                           // Initialization
3
4      create vertex set Q
5
6      for each vertex v in Graph:           
7          if v ≠ source
8              dist[v] ← INFINITY                 // Unknown distance from source to v
9          prev[v] ← UNDEFINED                    // Predecessor of v
10
11         Q.add_with_priority(v, dist[v])
12
13
14     while Q is not empty:                      // The main loop
15         u ← Q.extract_min()                    // Remove and return best vertex
16         for each neighbor v of u:              // only v that are still in Q
17             alt ← dist[u] + length(u, v) 
18             if alt < dist[v]
19                 dist[v] ← alt
20                 prev[v] ← u
21                 Q.decrease_priority(v, alt)
22
23     return dist, prev
]]--

function shortestpath (actor, target, targets) -- (elves[i], 'G', grems) or (grems[i], 'E', elves)
    local source = pos2hash(actor.x, actor.y)
    local dist = {[source]=0}
    local Q = newheap()
    local prev = {}
    Q:push(source, 0)

    local founds = {}

--    for x = 1, dimx do
--        for y = 1, dimy do
--            if arena[y][x] ~= '#' and actor.x ~= x and actor.y ~= y then
--                local v = pos2hash(x,y)
--                -- dist[v] = 100000000  -- test below will default
--                -- Q:push(v, 100000000) -- Q:decr will push if not there
--            end
--        end
--    end

    local found = 0

    while not Q:isempty() do
        local u,_ = Q:pop()
        local ux,uy = hash2pos(u)
        for y = uy-1, uy+1 do -- search for a path in "reading order"
            for x = ux-1, ux+1 do
                if    (x == ux or y == uy) -- no diagonal
                  and (x ~= ux or y ~= uy) -- different node
                  and x >= 1 and x <= xdim and y >= 1 and y <= ydim -- in bounds
                  and arena[y][x] ~= '#' -- not a wall
                  then
                    local alt = dist[u] + 1
                    local v = pos2hash(x,y)
                    if alt < (dist[v] or 100000000) then
                        dist[v] = alt
                        prev[v] = u
                        Q:decr(v, alt)
                    end
                    if arena[y][x] == target and not founds[v] then
                        founds[v] = true
                        found = found + 1
                    end
                end
            end
        end
        if found >= #targets then break end
    end

    actor.targets = found
    actor.dist = dist -- maps pos2hash(x,y) to distance
    actor.prev = prev -- maps path in reverse: pos2hash(x,y) -> pos2hash(x',y')
end

function distances (unit)
    local source = pos2hash(unit.x, unit.y)
    local dist = {[source]=0}
    local Q = newheap()
    Q:push(source, 0)

    while not Q:isempty() do
        local u,_ = Q:pop()
        local ux,uy = hash2pos(u)
        for y = uy-1, uy+1 do -- search for a path in "reading order"
            for x = ux-1, ux+1 do
                if    (x == ux or y == uy) -- no diagonal
                  and (x ~= ux or y ~= uy) -- different node
                  and x >= 1 and x <= xdim and y >= 1 and y <= ydim -- in bounds
                  and arena[y][x] ~= '#' -- not a wall
                  and arena[y][x] == '.' -- ?????????????????????????????
                  then
                    local alt = dist[u] + 1
                    local v = pos2hash(x,y)
                    if alt < (dist[v] or 100000000) then
                        dist[v] = alt
                        if arena[y][x] == '.' then -- TODO: only those, right?
                            Q:decr(v, alt)
                        end
                    end
                end
            end
        end
    end

    return dist -- maps pos2hash(x,y) to distance
end

--[[ https://en.wikipedia.org/wiki/Floyd%E2%80%93Warshall_algorithm

let dist be a {|V| * |V|} array of minimum distances initialized to infinity
let next be a {|V| * |V|} array of vertex indices initialized to null

procedure FloydWarshallWithPathReconstruction ()
   for each edge (u,v)
      dist[u][v] ← w(u,v)  // the weight of the edge (u,v)
      next[u][v] ← v
   for k from 1 to |V| // standard Floyd-Warshall implementation
      for i from 1 to |V|
         for j from 1 to |V|
            if dist[i][j] > dist[i][k] + dist[k][j] then
               dist[i][j] ← dist[i][k] + dist[k][j]
               next[i][j] ← next[i][k]

procedure Path(u, v)
   if next[u][v] = null then
       return []
   path = [u]
   while u ≠ v
       u ← next[u][v]
       path.append(u)
   return path
]]--

--[[
1 let dist be a |V| × |V| array of minimum distances initialized to ∞ (infinity)
2 for each edge (u,v)
3    dist[u][v] ← w(u,v)  // the weight of the edge (u,v)
4 for each vertex v
5    dist[v][v] ← 0
6 for k from 1 to |V|
7    for i from 1 to |V|
8       for j from 1 to |V|
9          if dist[i][j] > dist[i][k] + dist[k][j] 
10             dist[i][j] ← dist[i][k] + dist[k][j]
11         end if
]]--

function FloydWarshall ()
    local dist = {}
    -- construct vertices and initialize edge distances
    for uy = 1, ydim do
        for ux = 1, xdim do
            local u = pos2hash(ux,uy)
            local du = {[u] = 0}
            dist[u] = du
            if arena[uy][ux] ~= '#' then -- not a wall
                for y = uy-1, uy+1 do -- search for a path in "reading order"
                    for x = ux-1, ux+1 do
                        if    (x == ux or y == uy) -- no diagonal
                          and (x ~= ux or y ~= uy) -- different node
                          and x >= 1 and x <= xdim and y >= 1 and y <= ydim -- in bounds
                          and arena[y][x] == '.' -- can be occupied
                          then
                            du[pos2hash(x,y)] = 1
                        end
                    end
                end
            end
        end
    end
    local v = xdim * ydim - 1
    for k = 1, v do
        for i = 1, v do
            for j = 1, v do
                local dik = dist[i][k]
                local dkj = dist[k][j]
                local dij = dist[i][j] or 1000000000
                if dik and dkj and (dij > dik + dkj) then
                    dist[i][j] = dik + dkj
                end
            end
        end
    end
    return dist
end


-- function allpaths ()
--     for i = 1, #elves do
--         shortestpath(elves[i], 'G', grems)
--     end
--     for i = 1, #grems do
--         shortestpath(grems[i], 'E', elves) -- this is redundant... we can reverse the elves paths and distances
--     end
-- end

function poslt (x, y)
    return (x.y < y.y) or ((x.y == y.y) and (x.x < y.x))
end

function okiter (ux, uy, x, y)
    return (x == ux or y == uy) -- no diagonal
       and (x ~= ux or y ~= uy) -- different node
       and x >= 1 and x <= xdim and y >= 1 and y <= ydim -- in bounds
end

function findunit(units, x, y)
    for i = 1, #units do
        local targ = units[i]
        if targ.x == x and targ.y == y then
            return targ
        end
    end
    return nil
end

--[[
To attack, the unit first determines all of the targets that are in range of it by being 
immediately adjacent to it. If there are no such targets, the unit ends its turn. Otherwise, 
the adjacent target with the fewest hit points is selected; in a tie, the adjacent target with 
the fewest hit points which is first in reading order is selected.

The unit deals damage equal to its attack power to the selected target, reducing its hit points 
by that amount. If this reduces its hit points to 0 or fewer, the selected target dies: its 
square becomes . and it takes no further turns.
]]--

function attack (unit)

    local N = unit.y ~=    1 and arena[unit.y - 1][unit.x]
    local S = unit.y ~= ydim and arena[unit.y + 1][unit.x]
    local E = unit.x ~=    1 and arena[unit.y][unit.x + 1]
    local W = unit.x ~= xdim and arena[unit.y][unit.x - 1]

    local Nu = N == unit.t and findunit(unit.ts, unit.x, unit.y - 1)
    local Su = S == unit.t and findunit(unit.ts, unit.x, unit.y + 1)
    local Eu = E == unit.t and findunit(unit.ts, unit.x + 1, unit.y)
    local Wu = W == unit.t and findunit(unit.ts, unit.x - 1, unit.y)

    local targs = {Nu, Wu, Eu, Su}

    local minp = 100000000
    local mint = nil

    for i = 1, 4 do
        targ = targs[i]
        if targ then
            if targ.hit < minp then
                minp = targ.hit
                mint = targ
            end
        end
    end

    if mint then 
        mint.hit = mint.hit - unit.pwr
        printf("Attack %s%d -> %s%d(%d)\n", unit.c, unit.i, mint.c, mint.i, mint.hit)
        if mint.hit <= 0 then
            arena[mint.y][mint.x] = '.'
            -- TODO -- remove it from game?
            mint.y = 1
            mint.x = 0
        end
    end
    return mint
end

function ustep (unit, srep, targets)
    local mint = nil
    local mind = 10000000
    local minx = xdim + 1
    local miny = ydim + 1
    local posh = pos2hash(unit.x, unit.y)

    if attack(unit) then return 1 end

    local dist = distances(unit)

    local opponents = false

    for i = 1, #targets do
        local targ = targets[i]
        local uy = targ.y
        local ux = targ.x
        
        if targ.hit > 0 then
            opponents = true
            for y = uy-1, uy+1 do -- search for a target in "reading order"
                for x = ux-1, ux+1 do
                    if okiter(ux, uy, x, y) then
                        local d = dist[pos2hash(x, y)] or mind+1
                        --io.write(string.format("Check (%d,%d) to (%d,%d) = %d\n", unit.x, unit.y, x, y, d))
                        if d < mind or (d == mind and (y < miny or (y == miny and x < minx))) then
                            mind = d
                            minx = x
                            miny = y
                            mint = targ
                        end
                    end
                end
            end
        end
    end

    if not opponents then
        -- game over
        return -1
    end

    --print("Selected", minx, miny)

    if mint then
        
        local dist = distances(mint)
        -- move
        --local th = pos2hash(minx, miny)
        local N = unit.y ~=    1 and arena[unit.y - 1][unit.x] == '.' and dist[pos2hash(unit.x, unit.y - 1)] or 10000000
        local W = unit.x ~= xdim and arena[unit.y][unit.x - 1] == '.' and dist[pos2hash(unit.x - 1, unit.y)] or 10000000
        local E = unit.x ~=    1 and arena[unit.y][unit.x + 1] == '.' and dist[pos2hash(unit.x + 1, unit.y)] or 10000000
        local S = unit.y ~= ydim and arena[unit.y + 1][unit.x] == '.' and dist[pos2hash(unit.x, unit.y + 1)] or 10000000

        local minz = math.min(N, W, E, S)

        if verbose then
            printf("Selected (%d,%d) by (%d,%d) @%d N%d W%d E%d S%d\n", minx, miny, mint.x, mint.y, minz, N, W, E, S)
        end

        local x, y

        if N == minz then
            x = unit.x
            y = unit.y - 1
        elseif W == minz then
            x = unit.x - 1
            y = unit.y
        elseif E == minz then
            x = unit.x + 1
            y = unit.y
        else -- S
            x = unit.x
            y = unit.y + 1
        end

        arena[unit.y][unit.x] = '.'
        if verbose then
           io.write(string.format("Move %s%d (%d,%d) to (%d,%d)\n", unit.c, unit.i, unit.x, unit.y, x, y))
        end
        unit.x = x
        unit.y = y
        arena[unit.y][unit.x] = srep

        if attack(unit) then return 1 end

        return 0

    else
        printf("Stuck  %s%i\n", unit.c, unit.i)
        return 1
    end
end

local deadelves = {}
local deadgrems = {}

function prune (units, deadunits)
    local j = 1
    local jmax = #units
    for i = 1, jmax do
        if units[i].hit <= 0 then
            deadunits[#deadunits+1] = units[i]
        else
            units[j] = units[i]
            j = j + 1
        end
    end
    while j <= jmax do
        units[j] = nil
        j = j + 1
    end
end

local partialstep = 0

function showarena (i)
    print("After", i, "rounds")
    for y = 1, ydim do
        for x = 1, xdim do
            io.write(arena[y][x])
        end
        print""
    end
end


function step (i)

    local units = {}
    for i = 1, #elves do if elves[i].hit > 0 then units[#units+1] = elves[i] end end
    for i = 1, #grems do if grems[i].hit > 0 then units[#units+1] = grems[i] end end
    table.sort(units, poslt)

    local stuck = 0

    for i = 1, #units do
        local unit = units[i]
        if unit.hit > 0 then
            local op = ustep(unit, unit.c, unit.ts)
            if op < 0 then
                -- done
                partialstep = 1
                break
            else
                stuck = stuck + op
            end
        else
            stuck = stuck + 1
        end
    end

    if verbose then
        showarena (i)
    end

    prune(elves, deadelves)
    prune(grems, deadgrems)

    if stuck == #units then
        print("War")
        return true
    end
    return false

end

for i = 1, 100000000 do
    step(i)
    if #elves == 0 then
        print("Part 1 ends after", i, "-", partialstep)
        local score = 0
        for j = 1, #grems do
            score = score + ((i - partialstep) * grems[j].hit)
        end
        print("Part 1: Gremlins win, score is", score)
        showarena (i)
        break
    elseif #grems == 0 then
        print("Part 1 ends after", i, "-", partialstep)
        local score = 0
        for j = 1, #elves do
            score = score + ((i - partialstep) * elves[j].hit)
        end
        print("Part 1: Elves win, score is", score)
        showarena (i)
        break
    else
        printf("Elves: %d Grems: %d\n", #elves, #grems)
    end
end


print "Done"
