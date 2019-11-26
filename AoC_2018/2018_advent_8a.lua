

--[[
A header, which is always exactly two numbers:
The quantity of child nodes.
The quantity of metadata entries.
Zero or more child nodes (as specified in the header).
One or more metadata entries (as specified in the header).
]]--

infile = io.open("2018_advent_8a.txt")
input = infile:read("a")
infile:close()


summeta = 0

invec = {}

for v in string.gmatch(input, "(%d+)") do
    invec[#invec+1] = tonumber(v)
end

print ("Read ", #invec, "values")

function readtree (vec, i)
    local t = {}
    t.sz = vec[i]
    i = i + 1
    t.ms = vec[i]
    i = i + 1
    for j = 1, t.sz do
        c, e = readtree(vec, i)
        if e > #vec then print ("Error size ", e, #vec) end
        i = e
        t[j] = c
    end
    for j = 1, t.ms do
        local m  = vec[i]
        i = i + 1
        summeta = summeta + m
        t[j + t.sz] = m
    end
    return t, i
end

tree, vals = readtree(invec, 1)

if (vals ~= (#invec + 1)) then print ("WARNING ", vals, "not eq", #invec) end

print ("Part 1, Sum meta = ", summeta)

--[[
The value of a node depends on whether it has child nodes.

If a node has no child nodes, its value is the sum of its metadata entries.

However, if a node does have child nodes, the metadata entries become indexes which refer to those child nodes. 
A metadata entry of 1 refers to the first child node, 2 to the second, 3 to the third, and so on. 
The value of this node is the sum of the values of the child nodes referenced by the metadata entries. 
If a referenced child node does not exist, that reference is skipped. 
A child node can be referenced multiple time and counts each time it is referenced. 
A metadata entry of 0 does not refer to any child node.
]]

function treeval (t)
    local sum = 0
    if t.sz == 0 then
        for i = 1, t.ms do
            sum = sum + t[i]
        end
    else
        for i = 1, t.ms do
            local m = t[i + t.sz]
            if m < 1 or m > t.sz then
                -- skip
            else
                sum = sum + treeval(t[m])
            end
        end
    end
    return sum
end

print ("Part 2, Sum tree = ", treeval(tree))

print ("Done")

