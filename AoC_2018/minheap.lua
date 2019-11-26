
-- minheap.lua
-- http://lua-users.org/lists/lua-l/2007-07/msg00482.html
-- modifed with decr() added and new indxs to support that
-- Copyright (c) 2018 Doug Currie, Londonderry, NH, USA
-- Released under MIT/X11 license. See file LICENSE for details.

local _M = {}

_M._NAME    = "minheap"
_M._VERSION = "1.0.0"

local assert, setmetatable = assert, setmetatable

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

function _M.new ()
    return setmetatable({heap = {}, nodes = {}, indxs = {}},
            {__index = {push=push, pop=pop, decr=decr, isempty=isempty}})
end

--[[
local function test ()
    -- test heap
    local h = new()
    --for i=1,20 do h:push(i, math.random()) end
    --while not h:isempty() do print(h:pop()) end
    for i=1,2000 do h:push(i, math.random()) end
    local n = 0
    for i=1,2000 do local k,v = h:pop(); if v < n then print "Error in heap" end n = v end
    for i=1,2000 do h:push(i, math.random()) end
    for i=1,1000 do local i = math.floor(math.random() * 2000) + 1; h:decr(i, h.nodes[i] / 2.0) end
    local n = 0
    for i=1,2000 do local k,v = h:pop(); if v < n then print "Error in heap" end n = v end
end
]]--

return _M
