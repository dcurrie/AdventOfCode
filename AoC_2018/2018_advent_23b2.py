def get_bots(values):
    r = re.compile("pos=<([0-9-]+),([0-9-]+),([0-9-]+)>, r=([0-9]+)")
    bots = []
    for cur in values:
        m = r.search(cur)
        if m is None:
            # FIX: Use the right form of print for Python 3
            print(cur)
        bots.append([int(x) for x in m.groups()])
    return bots


def calc(values):
    bots = get_bots(values)
    best_i = None
    best_val = None
    for i in range(len(bots)):
        if best_i is None or bots[i][3] > best_val:
            best_val = bots[i][3]
            best_i = i

    bx, by, bz, bdist = bots[best_i]

    ret = 0

    for i in range(len(bots)):
        x, y, z, _dist = bots[i]

        if abs(x - bx) + abs(y - by) + abs(z - bz) <= bdist:
            ret += 1

    return ret


def calc2(values):
    bots = get_bots(values)
    # FIX: Adding [0] to each range to make sure it's tested for
    xs = [x[0] for x in bots] + [0]
    ys = [x[1] for x in bots] + [0]
    zs = [x[2] for x in bots] + [0]

    dist = 1
    while dist < max(xs) - min(xs):
        dist *= 2

    while True:
        target_count = 0
        best = None
        best_val = None
        for x in range(min(xs), max(xs) + 1, dist):
            for y in range(min(ys), max(ys) + 1, dist):
                for z in range(min(zs), max(zs) + 1, dist):
                    count = 0
                    for bx, by, bz, bdist in bots:
                        calc = abs(x - bx) + abs(y - by) + abs(z - bz)
                        # FIX: Python 3 changes how div works, we want integer math here
                        # FIX2: Deal with edge cases where the point is near the edge of the "dist" box
                        if dist == 1:
                            calc = abs(x - bx) + abs(y - by) + abs(z - bz)
                            if calc <= bdist:
                                count += 1
                        else:
                            calc = abs(x // dist - bx // dist) + abs(y // dist - by // dist) + abs(z // dist - bz // dist)
                            if calc - 1 <= bdist // dist:
                                count += 1
                    if count > target_count:
                        target_count = count
                        best_val = abs(x) + abs(y) + abs(z)
                        best = (x, y, z)
                    elif count == target_count:
                        if best_val is None or abs(x) + abs(y) + abs(z) < best_val:
                            best_val = abs(x) + abs(y) + abs(z)
                            best = (x, y, z)

        if dist == 1:
            print("The max count I found was: " + str(target_count))
            return best_val
        else:
            xs = [best[0] - dist, best[0] + dist]
            ys = [best[1] - dist, best[1] + dist]
            zs = [best[2] - dist, best[2] + dist]
            # FIX: Python 3 changes how div works, we want integer math here
            dist = dist // 2


def run(values):
    print("Nearest the big bot: " + str(calc(values)))
    print("Best location value: " + str(calc2(values)))
