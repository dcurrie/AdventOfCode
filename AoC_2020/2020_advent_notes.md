# Advent of Code 2020 -- e

Use reddit login to connect with Nim (Jabba Laci) leaderboard

## Notes

### Day 1: Report Repair ###

Didn't start on Dec 1, but Dec 2. Then realized I used github login by mistake,
so I redid this and day 2 on Dec 3. Pretty simple start as usual.

### Day 2: Password Philosophy ###

I had to go back and figure out how `scanf` control string works in Nim. Then it
was great, until I ran into trouble with Nim compiler cache. By naming p1.nim
and p2.nim the same as in Day 1, the compiler was using Day 1 programs to run my
code! So, for future reference, use
```
    nim c p1.nim
    ./p1
```
not
```
    nim r p1.nim
```

### Day 3: Toboggan Trajectory ###

After rerunning Day 1 and Day 2 on the reddit login's inputs, I got on with Day
3. The memoized recursive solution that worked for Part 1 failed on Part 2. I
still don't know why. Rewritten as non-memoized iterative it works fine. Oh
well.

### Day 4: Passport Processing ###

A very busy day at work, I squeezed in AoC work at lunchtime and between meetings.
I learned a bit about custom `scanf` matchers, including misleading documentation
at https://nim-lang.org/docs/strscans.html#user-definable-matchers -- when used
with $[] a matcher takes 2 arguments; with ${} it takes 3. I had assumed that the
string match result would be extracted by the `scanf` code using the match lenth
returned by the matcher. Rather, `scanf` expects a `var` arg to the matcher that
receives this string. Other than that, and silly string index arithmetic
off-by-one issues, it was all pretty easy.

Looking at others' solutions, it's nice to see zevv's use of NPeg, and
HugoGranstrom's `input.split("\n\n")` to separate the passports.

### Day 5: Binary Boarding ###

A little too easy, but a nice break for a snowy weekend day. I did the text to
binary conversion in the editor, and used `parseutils.parseBin` to get the seat
IDs. In part two Nim intsets came in handy. I couldn't help but thing it would
have been more elegant to start with a full set and remove seats seeing what's
left, but the brute force approach was easy and fast.

---

## Stats

Note: the times are from midnight EST; the challenges come out at midnight, but there's no way I'm starting them before breakfast, and usually lunch!

These are your personal leaderboard statistics. Rank is your position on that leaderboard: 1 means you were the first person to get that star, 2 means the second, 100 means the 100th, etc. Score is the number of points you got for that rank: 100 for 1st, 99 for 2nd, ..., 1 for 100th, and 0 otherwise.

```
      --------Part 1--------   --------Part 2--------
Day       Time   Rank  Score       Time   Rank  Score
  5   09:49:16  32846      0   10:05:06  31655      0
  4   13:22:15  47885      0   14:14:38  39618      0
  3   10:37:33  42244      0   11:43:19  42454      0
  2       >24h  75704      0       >24h  73340      0
  1       >24h  98813      0       >24h  92439      0
  ```

  Nim leaderboard starting from Day 4:

```
 65)  770 ****  dougcurrie
 60) 1059 *****  dougcurrie
```
