# Redis\Lua - Parking Airplanes

## Two solutions (+ one idea) and test

### 1. Lua arrays (implemented)

Using lua arrays for storing occupied and free places.

Pros: Not messing with redis DB.

Cons: More lines of code needed.

### 2. Redis sets (implemented)

Using new redis sets for storing occupied and free places.

Pros: Fewer lines of code needed and more elegant approach.

Cons: Messing with redis DB.

### 3. solution (idea)

If plane is not assigned, pick random place and check if it is taken. If not, assign it, else pick new random place.
  
Pros: if places are mostly unoccupied this would be fast approach.

Cons: if places are mostly occupied this would be slow approach.

### Test script checks if Lua scripts will return duplicate

Python script takes both solutions provided in Lua scripts and feeds them with list of 80 plane IDs (ordered and randomized).

Test if duplicate parking spot ID will be returned for different plane IDs.

Be careful if running local redis instance, script uses flushall().
