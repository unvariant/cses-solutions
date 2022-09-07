# PALINDROME REORDER

1. [Problem](#problem)
2. [Solution](#solution)
3. [Code Explanation](#explanation)
4. [Source](#source)

## Problem <a name="problem"></a>
![https://cses.fi/problemset/task/1755](imgs/problem.png)

## Solution <a name="solution"></a>
In order to build a palindrome, there can only be 0 or 1 characters with an odd occurance count. Otherwise it is impossible to build a palindrome, and instead `"NO SOLUTION"` is outputted.

Once a count of the character occurances is calculated, the palindrome can be built in two different ways.
1. build the left half of the palindrome, add the middle character (if any), add the right half of the palindrome

2. build the left and right halves simultaneously moving outward from the middle, add the middle character (if any) afterwards

## Code Explanation <a name="explanation"></a>


## Source <a name="source"></a>