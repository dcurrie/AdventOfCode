import strutils, sequtils, strscans, os, tables, math, algorithm

let
    params = commandLineParams()
    fname = if params.len > 0 :  params[0] else : "in1.txt"
    input = readFile(fname)

const
    qcards = 10007

var
    deck: array[0..(qcards-1), int]
    reversed = false
    offset = 0

proc dbgdeck() =
    echo "Offset: ", offset, " reversed: ", reversed, " :"
    echo deck

proc echodeck() =
    var i = offset
    for j in 0..(qcards-1):
        stdout.write($(deck[i]))
        stdout.write(",")
        i = (i + (if reversed: (qcards-1) else: 1)) mod qcards
    stdout.write("\n")

proc part1(input: string): int =
    reversed = false
    offset = 0
    for i in 0..(qcards-1):
        deck[i] = i
    for line in input.splitLines:
        var x: int
        if scanf(line, "deal into new stack"):
            reversed = not reversed
            offset = ((if reversed: (qcards-1) else: 1) + offset) mod qcards
        elif scanf(line, "deal with increment $i", x):
            # figure out how to do this in place
            var deck2 = deck
            var n = offset
            if not reversed:
                for i in 0..(qcards-1):
                    deck[n] = deck2[(i + qcards + offset) mod qcards]
                    n = (n + x) mod qcards
            else:
                var i = offset
                for j in 0..(qcards-1):
                    deck[n] = deck2[i]
                    i = (i + qcards - 1) mod qcards
                    n = (n + x) mod qcards
                reversed = not reversed
        elif scanf(line, "cut $i", x):
            offset = if reversed: (offset + qcards - x) mod qcards
                     else: (offset + qcards + x) mod qcards
        elif line == "":
            discard
        else:
            echo "Wtf: ", line
        #dbgdeck()
        #echodeck()
    echo "Offset: ", offset, " reversed: ", reversed
    for i in 0..(qcards-1):
        if deck[i] == 2019:
            echo "Found at ", i
            return (if reversed: offset + qcards - i else: i + qcards - offset) mod qcards

echo part1(input) # 5472

when defined(test1):
    echo part1("""deal with increment 7
deal into new stack
deal into new stack""")
    echodeck()

    echo part1("""cut 6
deal with increment 7
deal into new stack""")
    echodeck()
    echo deck

    echo part1("""deal with increment 7
deal with increment 9
cut -2""")
    echodeck()


    echo part1( """deal into new stack
cut -2
deal with increment 7
cut 8
cut -4
deal with increment 7
cut 3
deal with increment 9
deal with increment 3
cut -1
""")
    echodeck()

