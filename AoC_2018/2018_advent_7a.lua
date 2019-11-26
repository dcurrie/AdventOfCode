

--  Topological sorting

infile = io.open("2018_advent_7a.txt")
input = infile:read("a")
infile:close()


edges = {}
nodes = {}
qnode = 0

for x, y in string.gmatch(input, "Step (%a) must be finished before step (%a) can begin.") do
    edges[#edges+1] = {x, y}
    nodes[x] = true
    nodes[y] = true
end

for _,_ in pairs(nodes) do qnode = qnode + 1 end

print ("Read ", #edges, " edges", qnode, " nodes")

--[[ Kahn's Algorithm
L ← Empty list that will contain the sorted elements
S ← Set of all nodes with no incoming edge
while S is non-empty do
    remove a node n from S
    add n to tail of L
    for each node m with an edge e from n to m do
        remove edge e from the graph
        if m has no other incoming edges then
            insert m into S
if graph has edges then
    return error   (graph has at least one cycle)
else 
    return L   (a topologically sorted order)
]]

L = {}

S = {} -- initially all nodes
for k,_ in pairs(nodes) do S[k] = true end
-- remove nodes with incoming edges
for e = 1, #edges do S[edges[e][2]] = nil end

-- print ("Initial S")
-- for k,_ in pairs(S) do print(k) end

function nonempty (t)
    return next(t, nil)
end

function removesmallest (t)
    local smallest = 'ZZZZZ'
    for k,_ in pairs(t) do
        if k < smallest then smallest = k end
    end
    t[smallest] = nil
    return smallest
end

function findedge (n)
    for e = 1, #edges do
        if edges[e][1] == n then
            return e, edges[e][2]
        end
    end
    return false, false
end

function noin (m)
    for e = 1, #edges do
        if edges[e][2] == m then
            return false
        end
    end
    return true
end

while nonempty(S) do
    local n = removesmallest(S)
    L[#L+1] = n
    while true do
        local e, m = findedge(n)
        if e then
            table.remove(edges, e)
            if noin(m) then S[m] = true end
        else
            break
        end
    end
end

if #edges > 0 then print ("Error, graph has cycles.") end

print("Part 1: ", table.concat(L))

J = {} -- active jobs

W = { W1 = true, W2 = true, W3 = true, W4 = true, W5 = true  } -- available workers

local tick = 0

while nonempty(S) or nonempty(J) do
    while nonempty(S) and nonempty(w) do
        local n = removesmallest(S)
        local w = removesmallest(W) -- needed be smallest, but works
        J[#J+1] = {n, w, tick + 60 + string.byte(n, 1) - 0x41}
        print ("Start ", n, w, tick, tick + 60 + string.byte(n, 1) - 0x41)
    end
    if nonempty(J) then
        j = removenext(J)
        tick = j[3]    -- time has passed
        W[j[2]] = true -- worker available
        local n = j[1] -- completed step
        print ("Finish ", n, tick)
        while true do
            local e, m = findedge(n)
            if e then
                table.remove(edges, e)
                if noin(m) then S[m] = true end
            else
                break
            end
        end
    end
end

print("Part 2: ", tick)

print ("Done")

