
## Notes

### Day 1: The Tyranny of the Rocket Equation ###

Overcome some Nim syntax misunderstandings. Read the problem statement more carefully.

### Day 2: 1202 Program Alarm ###

Implement a simple VM...
Figured out Nim `seq` and `openarray` semantics; found string.split().
After that it was easy using brute force for part 2.

### Day 3: Crossed Wires ###

Bogged down with line segment intesection... used a general solution for "fun" despite the simplicity of horz. & vert. lines only. Bogged down with a logic error in part 2 (left loop early thinking I needed the min for each path separately despite the challenge being worded quite clearly). Nim documentation was good, but hard to navigate; I often knew exactly what 
I wanted but couldn't find the right module. Why isn't `zip` general?

### Day 4: Secure Container ###

The hardest task in part 1 was figuring out Nim syntax for integer modulo and divide (it's infix `mod` and `div`). Part 2 took two tries because I overlooked a case that wasn't covered by the examples: a pair followed by a larger group. That cost a couple minutes to suss out, but overall a pretty easy day.

### Day 5: Sunny with a Chance of Asteroids ###

This is the day that I learned that `var int` args are passed by reference by Nim. The  instruction `decode` function (that miraculously worked in part 1, and for all the test cases in parts 1 and 2) just happened to modify a critical vm opcode in part 2. Debugging was ugly.

### Day 6: Universal Orbit Map ###

Investment in dgraph data structure paid off! Punted implementing Tarjan's off-line lowest common ancestors algorithm in Nim and just used a hash table.


## Stats

Note: the times are from midnight EST; the challenges come out at midnight, but there's no way I'm starting them before breakfast, and usually lunch!

These are your personal leaderboard statistics. Rank is your position on that leaderboard: 1 means you were the first person to get that star, 2 means the second, 100 means the 100th, etc. Score is the number of points you got for that rank: 100 for 1st, 99 for 2nd, ...

##    --------Part 1--------   --------Part 2--------
Day       Time   Rank  Score       Time   Rank  Score
  6   10:59:28  11463      0   11:30:06  10315      0
  5   12:25:38  11095      0   13:49:33  10334      0
  4   11:23:21  18459      0   11:42:14  16259      0
  3   15:05:14  16815      0   16:08:25  14676      0
  2   12:20:39  20141      0   12:34:13  17294      0
  1   09:45:44  13415      0   09:56:30  11936      0

