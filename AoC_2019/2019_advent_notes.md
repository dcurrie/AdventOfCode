
# Advent of Code 2019 -- e

## Notes

### Day 1: The Tyranny of the Rocket Equation ###

Overcome some Nim syntax misunderstandings. Read the problem statement more carefully.

### Day 2: 1202 Program Alarm ###

Implement a simple VM...
Figured out Nim `seq` and `openarray` semantics; found string.split().
After that it was easy using brute force for part 2.

### Day 3: Crossed Wires ###

Bogged down with line segment intersection... used a general solution for "fun" despite the simplicity of horz. & vert. lines only. Bogged down with a logic error in part 2 (left loop early thinking I needed the min for each path separately despite the challenge being worded quite clearly). Nim documentation was good, but hard to navigate; I often knew exactly what 
I wanted but couldn't find the right module. Why isn't `zip` general?

### Day 4: Secure Container ###

The hardest task in part 1 was figuring out Nim syntax for integer modulo and divide (it's infix `mod` and `div`). Part 2 took two tries because I overlooked a case that wasn't covered by the examples: a pair followed by a larger group. That cost a couple minutes to suss out, but overall a pretty easy day.

### Day 5: Sunny with a Chance of Asteroids ###

This is the day that I learned that `var int` args are passed by reference by Nim. The  instruction `decode` function (that miraculously worked in part 1, and for all the test cases in parts 1 and 2) just happened to modify a critical vm opcode in part 2. Debugging was ugly.

### Day 6: Universal Orbit Map ###

Investment in dgraph data structure paid off! Punted implementing Tarjan's off-line lowest common ancestors algorithm in Nim and just used a hash table.

### Day 7: Amplification Circuit ###

Today I learned to slow down and when copying code from an earlier day's solution to be sure to get the later version with the fixes... I copied p1 from Day 5 instead of p2, and debugged the  `var int` arg problem again... this time it was much easier, but still a time waster. I got a late start (family day) and the part 2 description was unclear, but the examples helped. It's nice that Nim has `nextPermutation` built into the standard library.

### Day 8: Space Image Format ###

Pressed for time, I decided to use strings and explicit index computation instead of sussing out Nim 2D arrays. In the process I searched for a few minutes for `substring` before realizing that string slices was the Nim way. 

### Day 9: Sensor Boost ###

Refactored the vm to be an object. All my troubles today, few that there were, were Nim related. It took a few minutes to find `setLen` for adjusting vm memory size. The syntax for object initialization always feels wrong to me (why ':' characters, isn't that for types, not values!?). Why do large `int` literals not work when parseInt accepts them just fine!? I fought that for several minutes before I realized that inputting the IntCode program as text rather than as a sequence of literals solved the problem (which is how the solution worked anyway, only the test input was broken!).

### Day 10: Monitoring Station ###

Embarrassed that I had to figure out rotation of coordinates by trial and error. Learned about how Nim handles sort, deletion from sequences using `keepItIf` (is there an easier way?), and how it names `arctan2`. Reused collinear calculation from day 3.  N-cubed solution seems fast enough.

### Day 11: Space Police ###

Easy peasy... didn't even use the test cases... a little stumbling around with Nim syntax; use of a hash table was the right decision. 

### Day 12: The N-Body Problem ###

I had this completely solved (part 1 implemented, part 2 in my head), part 2 first by brute force, then realizing the axes were independent. Unfortunately, I had a logic bug in my termination condition, so I thought it was compute or memory bound, but in fact the algorithm was fine. I went onto reddit for the first time this season for hints, only to confirm that I was using the right approach. Once I found my logic bug the code ran in well under a second. 

### Day 13: Care Package ###

Part 1 was a piece of cake using day 11 code. Part 2 required displaying the world at the start to see where the walls are (not at the bottom!) and running the vm twice: once with instrumentation to see how the game worked, and once for "score." It wasn't clear what "tilt" meant... the first run cleared up that the paddle doesn't tilt, just translate on X axis. Overall, fun. No need to make real game interaction. I learned a bit about Nim's `enum` and `ord` and `template`.

### Day 14: Space Stoichiometry ###

It took me four attempts at an approach to part 2: brute force, looking for a cycle back to zero inventory of chemicals, convergence of the fuel per ore ratio, and finally the winner, binary search on the fuel result. Part 2 took way too long. Dunno if people are taking Saturday off, or if it was difficult, but I had a better rank than most days with my usual +10 hours start time.
Learned this after looking at other Nim solutions: `1_000_000_000_000.int` to work around int syntax issue for large int literals (day 9 also), and `t.getOrDefault(key)` for table access to avoid `if t.hasKey(key): t[key] else: 0`; others tended to use `ceil` after conversion to float and back to int rather than `+ 1` and `div`. zevv got the convergence of the fuel per ore ratio approach to work by using bigger fuel production steps.

### Day 15: Oxygen System ###

My Sunday has family time commitments... finally eeked in an hour to work on this in the mid afternoon. I got off to a false start trying to keep a backtrack stack within the i/o functions, and keep the vm as the top level driver of the solution. Eventually this got too complicated, and I restarted with a recursive solution to develop the map. This worked much better. Once I had the map, my graph toolkit quickly found the part 1 and part 2 values. I learned the awkward Nim syntax for unicode `Runes` to make the debug display of the map a bit nicer. Later, looking at solutions and reddit, I see that my DFS approach to part 1a (mapping the world) assumed a finite world; fortunately that was true! The most clever solutions used BFS and cloned the vm for backtracking to avoid having to walk back the droid in the vm... clever.
Fun unicode: '☕⚪⚫⚽⛅⛔⛪⛳⛵⛺✨❌❎➰➿⬛⬜⭐⭕'

### Day 16: Flawed Frequency Transmission ###

Part 1 was kinda ugly but straightforward via brute force. That didn't work for part 2. Frankly, I was stumped, and after an hour or so, turned to reddit for a hint. I knew the growing number of zeros on the front of the "fft" calculation provided an optimization opportunity, but missed the two big observations: that the coefficients would all be 1 in the region of interest, and that therefore the calculation devolved into partial sums.
Good explanation [here](https://github.com/mebeim/aoc/blob/master/2019/README.md#day-16---flawed-frequency-transmission), which is what I used as a model for my implementation. Re: Nim... I stumbled a few minutes figuring out that HSlices can't run backwards, so `for i in 3..1` needs to be written as `for i in countdown(3,1)`.

### Day 17: Set and Forget ###

Part 1 was no problem using my `dgraph` library to find intersections. I noticed in the graph that there are two dead end nodes: the start, and what could only be the end. Then I had a couple failed attempts... the shortest path from start to end didn't cover all nodes, which should have been obvious. I left this approach in the code. Then I researched (NP-hard!) path covering and maximum path algorithms and despaired. Finally I tried a heuristic: go straight through intersections, if can't continue straight, go left if possible, otherwise go right. It worked! Having to segment that path programmatically seemed like too much work, so I did that using my text editor. The rest was easy once I remembered that I needed to reverse the input since my vm `pop`s the inputs off the input sequence.

### Day 18: Many-Worlds Interpretation ###

I can take zero credit for figuring this out. My initial solution did a Dijkstra shortest path search with doors closed, choosing one reachable key at a time, adding the door edges as keys are chosen, exploring all possible paths by cloning the state at each choice. It works great for small examples, which included 4 of the 5 examples. Combinatorial explosion ensued. After banging my head against the wall, I went to the solution thread on reddit, and found [this Lua solution](https://www.reddit.com/r/adventofcode/comments/ec8090/2019_day_18_solutions/fb9zet8?utm_source=share&utm_medium=web2x) [source](https://github.com/jwise/aoc/blob/master/2019/18.lua). I translated to Nim, which wasn't a picnic, and solved my challenge. I think adding memoization to my original version would have achieved the same result. 

### Day 19: Tractor Beam ###

I got a false start thinking that the vm ran continuously. When I tried cloning it for every trial, it worked. At that point part 1 was trivial. For part two I estimated the start of the search area using some targeted exploration to find the slopes of the beam, then extended the code to search that space looking for the rectangle, which amazing worked the first try.

### Day 20: Donut Maze ###

I solved part 1 quickly with my dgraph library, and had the solution, **twice**! for part 2 (both versions worked on samples), but a bug in the input processor incorrectly characterized inner and outer ports. Ugh! Nevertheless, even after 24 hours, I was 2184 on the leaderboard. I guess it was hard.

### Day 21: Springdroid Adventure ###

This was 3 instruction combinatorial logic. Part 1 was easy, even after finishing Donut Maze a little after midnight (after party and beer). Part 2 included a zinger of jump of 5 after a running start rather than the usual 4. That sent me to bed. Rising late, I worked it out, but it was work. I left lots of fumbled attempts and notes in the code.

---

## Stats

Note: the times are from midnight EST; the challenges come out at midnight, but there's no way I'm starting them before breakfast, and usually lunch!

These are your personal leaderboard statistics. Rank is your position on that leaderboard: 1 means you were the first person to get that star, 2 means the second, 100 means the 100th, etc. Score is the number of points you got for that rank: 100 for 1st, 99 for 2nd, ...

```
      --------Part 1--------   --------Part 2--------
Day       Time   Rank  Score       Time   Rank  Score
 21   01:39:33    852      0   13:23:13   2022      0
 20   11:58:42   2183      0       >24h   2148      0
 19   10:50:59   3455      0   11:53:04   2634      0
 18   22:19:04   1806      0   23:08:25   1378      0
 17   14:10:52   4783      0   18:34:29   3545      0
 16   10:57:37   4763      0   14:23:00   2652      0
 15   15:07:03   3935      0   15:14:36   3585      0
 14   10:47:14   3317      0   12:17:27   3027      0
 13   10:56:01   6594      0   12:00:49   4841      0
 12   11:36:20   7303      0   14:19:43   5029      0
 11   12:52:11   6387      0   13:16:19   6192      0
 10   10:49:04   6720      0   13:51:06   5115      0
  9   15:55:44   8837      0   15:56:35   8741      0
  8   09:48:19  10092      0   10:09:50   9331      0
  7   16:43:19  11188      0   17:32:58   7666      0
  6   10:59:28  11463      0   11:30:06  10315      0
  5   12:25:38  11095      0   13:49:33  10334      0
  4   11:23:21  18459      0   11:42:14  16259      0
  3   15:05:14  16815      0   16:08:25  14676      0
  2   12:20:39  20141      0   12:34:13  17294      0
  1   09:45:44  13415      0   09:56:30  11936      0
```
