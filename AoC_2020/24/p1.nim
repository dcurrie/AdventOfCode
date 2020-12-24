import strutils, sequtils, complex, hashes, strscans, os, sets, tables, parseutils, sugar, algorithm

let
    params = commandLineParams()
    fname = if params.len > 0 : params[0] else : "input.txt"
    input = readFile(fname)

#echo("Params: ", params)

#type Posn: tuple(x:int, y:int)

# e, se, sw, w, nw, and ne

proc hash(x: Complex[float64]): Hash =
  ## Computes a Hash from `x`.
  var h: Hash = 0
  h = h !& hash(x.re)
  h = h !& hash(x.im)
  result = !$h

proc readIn(input: string): Table[Complex[float64],bool] =
    for line in input.strip.splitLines:
        var pos = complex[float64](0, 0)
        var i = 0
        while i < line.len:
            var c = line[i]
            case c:
            of 'e': pos += complex[float64](2, 0)
            of 'w': pos += complex[float64](-2, 0)
            of 's':
                i += 1
                case line[i]:
                of 'e': pos += complex[float64](1, -1)
                of 'w': pos += complex[float64](-1, -1)
                else: echo("wtf s", i, " ", line) # discard
            of 'n':
                i += 1
                case line[i]:
                of 'e': pos += complex[float64](1, 1)
                of 'w': pos += complex[float64](-1, 1)
                else: echo("wtf n", i, " ", line) # discard
            else:
                echo("wtf  ", i, " ", line) # discard
            i += 1
        if result.hasKey(pos):
            result[pos] = not result[pos]
        else:
            result[pos] = true

proc part1(input: string): int =
    var lobby = readIn(input)
    for x in values(lobby):
        if x:
            result += 1

echo("Part 1 ex : ", part1("""sesenwnenenewseeswwswswwnenewsewsw
neeenesenwnwwswnenewnwwsewnenwseswesw
seswneswswsenwwnwse
nwnwneseeswswnenewneswwnewseswneseene
swweswneswnenwsewnwneneseenw
eesenwseswswnenwswnwnwsewwnwsene
sewnenenenesenwsewnenwwwse
wenwwweseeeweswwwnwwe
wsweesenenewnwwnwsenewsenwwsesesenwne
neeswseenwwswnwswswnw
nenwswwsewswnenenewsenwsenwnesesenew
enewnwewneswsewnwswenweswnenwsenwsw
sweneswneswneneenwnewenewwneswswnese
swwesenesewenwneswnwwneseswwne
enesenwswwswneneswsenwnewswseenwsese
wnwnesenesenenwwnenwsewesewsesesew
nenewswnwewswnenesenwnesewesw
eneswnwswnwsenenwnwnwwseeswneewsenese
neswnwewnwnwseenwseesewsenwsweewe
wseweeenwnesenwwwswnew"""))

echo("Part 1 : ", part1(input))
