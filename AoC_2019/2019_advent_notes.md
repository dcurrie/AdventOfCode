
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

---

## Stats

Note: the times are from midnight EST; the challenges come out at midnight, but there's no way I'm starting them before breakfast, and usually lunch!

These are your personal leaderboard statistics. Rank is your position on that leaderboard: 1 means you were the first person to get that star, 2 means the second, 100 means the 100th, etc. Score is the number of points you got for that rank: 100 for 1st, 99 for 2nd, ...

```
      --------Part 1--------   --------Part 2--------
Day       Time   Rank  Score       Time   Rank  Score
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
