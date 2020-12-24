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

proc readIn(input: string): Table[Complex[float64],int] =
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
            result[pos] = 1 - result[pos]
        else:
            result[pos] = 1

proc part1(input: string): int =
    var lobby = readIn(input)
    for x in values(lobby):
        result += x

# Every day, the tiles are all flipped according to the following rules:
#
# Any black tile with zero or more than 2 black tiles immediately adjacent to it is flipped to white.
# Any white tile with exactly 2 black tiles immediately adjacent to it is flipped to black.
# Here, tiles immediately adjacent means the six tiles directly touching the tile in question.
#
# The rules are applied simultaneously to every tile; put another way, it is first
# determined which tiles need to be flipped, then they are all flipped at the same time.

proc neighbors(p: Complex[float64]): array[6, Complex[float64]] =
    result = [p + complex[float64](2, 0),
              p + complex[float64](-2, 0),
              p + complex[float64](1, -1),
              p + complex[float64](-1, -1),
              p + complex[float64](1, 1),
              p + complex[float64](-1, 1)]


proc part2(input: string): int =
    var lobby = readIn(input)
    var nobby: Table[Complex[float64],int]
    var work: seq[Complex[float64]] # work list, all white
    for i in 1..100:
        nobby.clear
        work = @[]
        for p,b in pairs(lobby):
            var ns = neighbors(p)
            var cnt = 0
            for n in ns: cnt += lobby.getOrDefault(n,0)
            if b == 1:
                if cnt == 0 or cnt > 2:
                    # flip to white
                    discard
                else:
                    nobby[p] = 1
                for n in ns:
                    if not lobby.hasKey(n):
                        work.add(n)
            else:
                work.add(p)
        for p in work:
            var ns = neighbors(p)
            var cnt = 0
            for n in ns: cnt += lobby.getOrDefault(n,0)
            if cnt == 2:
                nobby[p] = 1
        lobby = nobby
        # var tst = 0
        # for x in values(lobby):
        #     tst += x
        # echo("Day ", i, ": ", tst)
    for x in values(lobby):
        result += x


echo("Part 2 ex : ", part2("""sesenwnenenewseeswwswswwnenewsewsw
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

echo("Part 2 : ", part2(input))
