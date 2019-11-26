

--  [1518-11-01 00:00] Guard #10 begins shift
--  [1518-11-01 00:05] falls asleep
--  [1518-11-01 00:25] wakes up

infile = io.open("2018_advent_4a.txt")
input = infile:read("a")
infile:close()

local events = {}
local stamps = {}
local nevents = 0

for date, evtype in input:gmatch "%[(%d%d%d%d%-%d%d%-%d%d %d%d:%d%d)%] (%a+ %a+)"  do
    events[date] = evtype
    nevents = nevents + 1
    stamps[nevents] = date
end
for date, gnum in input:gmatch "%[(%d%d%d%d%-%d%d%-%d%d %d%d:%d%d)%] Guard #(%d+) begins shift" do
    events[date] = tonumber(gnum)
    nevents = nevents + 1
    stamps[nevents] = date
end

table.sort(stamps)

print("Input ", nevents, " events", #stamps, " timestamps")

local guard = -1
local dosets = ''
local snooze = {}

function tsdiff (endts, start)
    if endts:sub(1,14) == start:sub(1,14) then
        -- same hour
        return tonumber(endts:sub(15,16)) - tonumber(start:sub(15,16))
    else
        print ("Error not same hour ", endts, start)
        return 0
    end
end

for i = 1, #stamps do
    ts = stamps[i]
    ev = events[ts]
    ty = type(ev)
    if ty == 'number' then
        guard = ev
    elseif ev == 'falls asleep' then
        dosets = ts
    elseif ev == 'wakes up' then
        snooze[guard] = (snooze[guard] or 0) + tsdiff(ts, dosets)
    else
        print ("Unknown event: ", ev)
    end
end

local maxsnooze = 0

for k,v in pairs(snooze) do
    if v > maxsnooze then
        guard = k
        maxsnooze = v
    end
end

print ("Sleepy guard ", guard, "has max snooze ", maxsnooze)

local snosecs = {}
local     gu = -1

function secs (ts)
    return tonumber(ts:sub(15,16))
end

for i = 1, #stamps do
    ts = stamps[i]
    ev = events[ts]
    ty = type(ev)
    if ty == 'number' then
        gu = ev
    elseif ev == 'falls asleep' then
        dosets = ts
    elseif ev == 'wakes up' and gu == guard then
        for i = secs(dosets), secs(ts) - 1 do
            snosecs[i] = (snosecs[i] or 0) + 1
        end
    end
end

local maxsec = 0
local maxhit = 0

for k,v in pairs(snosecs) do
    if v > maxsec then
        maxhit = k
        maxsec = v
    end
end

print ("Sleepy guard ", guard, "has max snooze sec ", maxhit, maxsec, "times!")

print ("Result part 1 = ", guard * maxhit)

local gsnosecs = {}

for k,v in pairs(snooze) do
    gsnosecs[k] = {}
end

for i = 1, #stamps do
    ts = stamps[i]
    ev = events[ts]
    ty = type(ev)
    if ty == 'number' then
        gu = ev
    elseif ev == 'falls asleep' then
        dosets = ts
    elseif ev == 'wakes up' then
        local snosecs = gsnosecs[gu]
        for i = secs(dosets), secs(ts) - 1 do
            snosecs[i] = (snosecs[i] or 0) + 1
        end
    end
end

local guard2 = -1
local maxsec2 = 0
local maxhit2 = 0

for g2, snosecs in pairs(gsnosecs) do
    for k,v in pairs(snosecs) do
        if v > maxsec2 then
            maxhit2 = k
            maxsec2 = v
            guard2 = g2
        end
    end
end

print ("Sleepy guard ", guard2, "has max snooze sec ", maxhit2, maxsec2, "times!")

print ("Result part 2 = ", guard2 * maxhit2)


print ("Done ")

