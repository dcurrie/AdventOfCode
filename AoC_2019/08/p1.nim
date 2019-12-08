import strutils, sequtils, strscans, os, tables, algorithm

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "in1.txt"
    input = readFile(fname).splitLines


proc readin(): string =
    for line in input:
        if line.len mod (25 * 6) == 0:
            result = line
        else:
            echo "Line len: ", line.len
            result = ""

proc part1() =
    let input = readin()
    let layers = input.len div (25 * 6)
    #echo "Layers ", layers
    # Find the layer that contains the fewest 0 digits.
    var minz = (25 * 6) + 1
    var zlayer = -1
    for i in 0..(layers-1):
        var cntz = 0
        for j in (i * (25 * 6))..(((i+1) * (25 * 6)) - 1):
            if input[j] == '0':
                cntz += 1
        if cntz < minz:
            minz = cntz
            zlayer = i
        #echo "Layer ", i, " zeros ", cntz, if zlayer == i: "******" else: ""
    # On that layer, what is the number of 1 digits multiplied by the number of 2 digits?
    var cnt1 = 0
    var cnt2 = 0
    for j in (zlayer * (25 * 6))..(((zlayer+1) * (25 * 6)) - 1):
        if input[j] == '1':
            cnt1 += 1
        elif input[j] == '2':
            cnt2 += 1
    echo "Part 1: ", cnt1 * cnt2

part1()

proc part2() =
    let input = readin()
    let layers = input.len div (25 * 6)
    var outline = "abcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxy"
    # 0 is black, 1 is white, and 2 is transparent
    for j in 0..((25 * 6) - 1):
        for i in 0..(layers-1):
            if input[i * (25 * 6) + j] == '0':
                outline[j] = ' '
                break
            if input[i * (25 * 6) + j] == '1':
                outline[j] = '#'
                break
    for k in 0..5:
        echo outline[(k * 25)..(((k + 1) * 25) - 1)]

part2()


