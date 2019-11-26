
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
