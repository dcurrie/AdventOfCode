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
string match result would be extracted by the `scanf` code using the match length
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

### Day 6: Custom Customs ###

I would have finished this one very quickly (after starting at 1:30 PM after
annual condo meetings) if only I paid more attention to the line splitting and
its affect on counts since the input file ended with a '\n' whereas no other
group of lines did after I split them up. Anyway, I was able make use of
HugoGranstrom's `input.split("\n\n")` to separate the groups, and learned a bit
about Nim sequtils... wishing I used Julia for this one.

### Day 7: Handy Haversacks ###

Nim Tables came in handy, though a quick search didn't turn up a `reduce` or
`fold` for Tables, so I resorted to a loop. Recursion for the counts was
straightforward, or should have been if not for off-by-one tuning. I avoided
the more complex parsing by using search/replace in the text editor on the input.

### Day 8: Handheld Halting ###

OK time for the VM! Actually, I did it all from scratch using strings for ops
and parsed operands, so I wasn't going for speed, though Nim was plenty fast
enough. I tripped up over tuple syntax, and anonymous function syntax, but
eventually made good use of the sugar module for `collect` and `=>`.

Looking at other Nim solutions I learned of `parseEnum`, which will be useful
if this VM gets more use in future days. I was also reminded of the usefulness
of having a VM state object that can be used to pass the pgm and acc around.

### Day 9: Encoding Error ###

This was fun. Nim CountTable was perfect, and I got part 1 on the first try with
no fuss once I looked into how to decrement a CountTable entry. Part two was
easy using slices and sequtils, though I had to submit twice because I overlooked
terminating the re-use of part 1 correctly after changing a `return` to an
assignment and neglecting the `break`. Once I added that, it worked fine.

### Day 10: Adapter Array ###

The part 2 combinatorics caused a bit of math head scratching that I abandoned
after several minutes and decided on a brute force computational approach.
This worked fine on the example, after some debugging of the combinations of
results of the recursion, but blew up for the real input. Adding memoization
was easy and solved the performance problem.

### Day 11: Seating System ###

Cellular Automata day! Struggled with the syntax for `foldl` macro with mixed
types (backwards from what I initially guessed), and managing Enums. I was
thinking Julia would have been much easier. Once I was able to compile,
the solutions to Parts 1 and 2 both worked the first time. I was lucky to
choose Empty ('L') for padding to avoid special cases at the boundaries in
Part 1, because it made the termination of the search in each direction
trivial and automatic in Part 2.

### Day 12: Rain Risk ###

Following directions. I decided to learn about Complex in Nim, a fortuitous
choice because the conversion from Part 1 to Part 2 was almost trivial: change
the starting condition, and about two lines of code. Hooray. Again, once the
code compiled (as I figured out Nim syntax) it ran first time.

### Day 13: Shuttle Search ###

Chinese Remainder Theorem day! I had a sieve solution working for the examples
in part 2, but of course it was too slow for the solution. Once I got the hint
that CRT is needed, I dusted off a Lobster implementation I did for Rosetta
Code project, struggled with `foldl` syntax again, and once it compiled it
worked first time run in the blink of an eye.

### Day 14: Docking Data ###

This was a struggle, mainly because I was trying to doo it while in a business
meeting (on Google Meet) and distractions caused steupid errors. For example,
in Part 1 I neglected to clear the hash table after the unit test so it had
crap in it when I ran the input for score. The I got stuck because I took the
36-bit memory too literally, and produced an answer mod 2^36 when in fact AoC
was expecting a true sum. Yuck. Part two was a small head scratcher, but easy
enough once I got out of that meeting with a recursive counting function.
Fortunately I already knew the x&(x-1) hack to clear the lowest set bit.

What I learned later looking at others' solutions: Nim has 64 bit `int`s, so
all the trouble I took with typecasts wasn't necessary (and was a pain).


### Day 15: Rambunctious Recitation ###

So many off by one errors... I was working in Julia last night, which has
1-based arrays by default, and made several miscalculations due to that since
Nim is 0=based. I started using a hash table for part one, scrapped it for a
simple search to find previous, which utterly failed on part 2. So, I broke
down and made the hashtable, and after fixing more off-by-one problems, it
worked fairly quickly.

What I learned later looking at others' solutions: Hugo Granstrom's use of an
array for the pairs is clever: the max index is the size of the problem, so it
will be sparse, but probably less memory overall than the hash table, and faster
to boot. I am embarrassed I didn't get the pipelined solution that Miran
(narimiran) found. I had an inkling of it, but proceeded to code too quickly.
That solution avoids the pairs altogether since it defers storing the index in
the hash table. Combining the two approaches above would be cool.

### Day 16: Ticket Translation ###

Part 1 was straightforward after parsing the data; one silly error (same as
before, failing to reinitialize). As expected, Part 2 was a constraint problem.
In business meetings again, solved the example using all permutations of the
fields, not taking the time to calculate the number of permutations needed for
the input... of course there was lots of time to do that while the computer
whirred...2432902008176640000.
So, when the meeting was over, I redid it using a smarter approach, which
amazingly worked as soon as it compiled. I learned a lot about syntax for Nim
sets and stumbled on syntax to convert iterators to sequences.


### Day 17: Conway Cubes ###

I'm ticked off with this one. I had a good approach from the start based on my
interpretation of the statement and rules that this would be a sparse array: Nim
HashSets. I chose an array of neighbor offsets to iterate through. I wish I had
not... for an hour or more I was getting the wrong results on the example. I was
confused, as were others, by the shift in coordinates in the example; doubly so
since my code was giving different results. In desperation I switched from the
array of neighbor offsets to nested loops iterating over the same offsets, and
the code worked! I still do not understand what was wrong with my initial
solution. Once that was working, part 2 was a piece of cake, just one more inner
loop.

OK, there was a typo in the array of neighbor offsets. I blame my aging eyes,
since I checked it visually several times. Yuck. It sucks to get old.

### Day 18: Operation Order ###

This was amusing. I did Part 1 as a simple pushdown automata with separate
stacks for values and operations. It was a nice little exercise, no real
challenges. For Part 2, operator precedence was needed, and though I recall
using clever precedence parsing algorithms, including Pratt, and recursive
descent, I thought there might be something simpler. Lo and behold, a quick
search turned up [this FORTRAN I compiler gem!](https://en.wikipedia.org/wiki/Operator-precedence_parser#Alternative_methods) It's just a string substitution
to add parens in one pass, and then the simple Part 1 automata. What a hack!

Later: I realize after reading others's solutions that my pushdown automata is
a simplified (no precedence) shunting-yard algorithm (for infix to postfix
conversion) with integrated interpreter.

### Day 19: Monster Messages ###

OK, so this took waaay longer than I expected. Good thing it was a pandemic
Saturday. It took a while to debug Part 1; I was looking for a problem in the
recognizer (part1) but the problem was really in the input parser leaving the
trailing rule ID off each alternate in a rule. Of course, that was obvious
once I dumped the scanned rules, but I was focused on the recognizer engine.
Part 2 was another kettle of fish. Part 1 was using a greedy algorithm
unsuitable for recursion in the grammar. I first tried backtracking and got
wrapped around the axle. I decided to just use "loop unrolling" to a few levels
of recursion, and then brute force try all possibilities. Once it all compiled
it worked first time... too bad it took a couple hours to code it!

---

## Stats

Note: the times are from midnight EST; the challenges come out at midnight, but there's no way I'm starting them before breakfast, and usually lunch!

These are your personal leaderboard statistics. Rank is your position on that leaderboard: 1 means you were the first person to get that star, 2 means the second, 100 means the 100th, etc. Score is the number of points you got for that rank: 100 for 1st, 99 for 2nd, ..., 1 for 100th, and 0 otherwise.

```
      --------Part 1--------   --------Part 2--------
Day       Time   Rank  Score       Time   Rank  Score
 19   10:40:52   9410      0   12:43:20   7483      0
 18   09:10:57  12338      0   09:44:55  10604      0
 17   10:58:59  12673      0   11:05:42  11793      0
 16   09:18:26  16907      0   10:51:29  12967      0
 15   08:57:54  17834      0   09:15:26  16005      0
 14   09:23:32  17306      0   10:22:53  13705      0
 13   07:56:15  20770      0   09:51:27  11686      0
 12   08:36:04  19652      0   08:43:34  16334      0
 11   09:46:19  21387      0   10:17:58  17231      0
 10   08:44:24  28271      0   10:12:05  18605      0
  9   08:28:39  28096      0   08:49:30  26436      0
  8   08:50:51  30015      0   09:09:57  25790      0
  7   09:37:01  24973      0   10:11:17  21353      0
  6   13:42:16  43976      0   13:59:07  41934      0
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
 66) 1323 ******  dougcurrie
 44) 1645 *******  dougcurrie
 52) 1941 ********  dougcurrie
 50) 2241 *********  dougcurrie
 49) 2556 **********  dougcurrie
 44) 2885 ***********  dougcurrie
 39) 3210 ************  dougcurrie
 37) 3557 *************  dougcurrie
 37) 3891 **************  dougcurrie
 36) 4249 ***************  dougcurrie
 34) 4603 ****************  dougcurrie
 33) 4946 *****************  dougcurrie
 31) 5277 ******************  dougcurrie
 25) 5638 *******************  dougcurrie
 ```
