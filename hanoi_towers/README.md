# TOWERS OF HANOI

1. [Problem](#problem)
2. [Solutions](#solution)
3. [Leaderboard](#leaderboard)

## Problem <a name="problem"></a>
![https://cses.fi/problemset/task/2165/](imgs/problem.png)

## Solutions <a name="solutions"></a>
### Representations of the towers of hanoi state
1. Bitmap
Each pole can be represented using a u32 where a pole contains disk i if bit i is set in that pole.

2. 64 bit Stack
One of the problem constraints states that n is less than or equal to 16. A single u64 can be used to store the entire state of a single pole, with 16 four bit elements. Each element represents a disk number. A push operation consists of a 4 bit left shift and a bitwise or. A pop operation is a single 4 bit right shift.

### Grey code solution
[https://en.wikipedia.org/wiki/Tower_of_Hanoi#Gray-code_solution](https://en.wikipedia.org/wiki/Tower_of_Hanoi#Gray-code_solution)

The grey code is a set of bit strings each of length *n* where the [Hamming distance](https://en.wikipedia.org/wiki/Hamming_distance) between each consectutive bit string is 1.

```x86asm
;;; example grey code of length 2
00
01
11
10
```

There is actually a relationship between the grey code and the tower of hanoi. If the disks are numbers from n-1 to 0 (starting at the largest disk and ending at the smallest disk) the bit index of the bit that changes between consectutive strings in the grey code corresponds to the disk number that must be moved for that iteration.

| towers of hanoi | grey code |
|-----------------|-----------|
| <pre>0\| \|<br>1\| \|<br>-----<br></pre> | <pre>00 ^ 01 = 01 (bit 0)</pre> |
| <pre> \| \|<br>1\|0\|<br>-----<br></pre> | <pre>01 ^ 11 = 10 (bit 1)</pre> |
| <pre> \| \|<br> \|0\|1<br>-----<br></pre> | <pre>11 ^ 10 = 01 (bit 0)</pre> |
| <pre> \| \|0<br> \| \|1<br>-----<br></pre> | <pre>done</pre> |

This gives the disk number that must move for the current towers of hanoi iteration, but not the src and dst poles. There is a fairly straight forward way to calculate these values.

```rs
if disk number == 0 {
    cycle = if n is even {
        [1, 2, 0]
    } else {
        [2, 1, 0]
    };
    src = cycle [iteration - 1];
    dst = cycle [iteration];
} else {
    src = find the pole that contains disk number;
    dst = guaranteed only one valid movement;
}
```

### Modulo solution
[https://en.wikipedia.org/wiki/Tower_of_Hanoi#Simpler_statement_of_iterative_solution](https://en.wikipedia.org/wiki/Tower_of_Hanoi#Simpler_statement_of_iterative_solution)

## Leaderboard
![https://cses.fi/problemset/stats/2165/](imgs/standings.png)
3rd fastest as of 2022 September 8 23:35