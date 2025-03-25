# Get largest prime

## Task

Find the bigest prime number in the matrix. In the matrix you can move only **right** and **down**,
starting by any cell of first column or first row.

We can consider a number completed, if `Idx(n)` = `N` or `Idx(m)` = `M`

If you don't find any prime number, return with _-1_

## Constraints

The matrix dimensions is `MxN`\
where 1 &lt;= `N` &lt;= 9 \
and 1 &lt;=`M` &lt;= 9

and each number in the matrix is 0 &lt;= **M**<sub>mn</sub> &lt;= 9

## Examples

### 1st

let this matrix = **M** (2x2)

|       | **1** | **2** |
| :---- | :---: | :---: |
| **1** |  _1_  |  _3_  |
| **2** |  _5_  |  _7_  |

primes are

- 3 =&gt; **M**<sub>12</sub>
- 7 =&gt; **M**<sub>22</sub>
- 13 =&gt; **M**<sub>11</sub>x10 + **M**<sub>12</sub>
- 37 =&gt; **M**<sub>11</sub>x10 + **M**<sub>12</sub>
- 137 =&gt; **M**<sub>11</sub>x10<sup>2</sup> + **M**<sub>12</sub>x10 + **M**<sub>22</sub>
- 157 =&gt; **M**<sub>11</sub>x10<sup>2</sup> + **M**<sub>21</sub>x10 + **M**<sub>22</sub>

the largest prime is _157_

### 2nd

|       | **1** | **2** | **3** |
| :---- | :---: | :---: | :---: |
| **1** |  _5_  |  _2_  |  _5_  |
| **2** |  _4_  |  _7_  |  _0_  |
| **3** |  _6_  |  _7_  |  _9_  |

the largest prime is _54779_

### 3rd

|       | **1** | **2** | **3** |
| :---- | :---: | :---: | :---: |
| **1** |  _2_  |  _3_  |  _3_  |
| **2** |  _0_  |  _9_  |  _9_  |
| **3** |  _6_  |  _9_  |  _1_  |

the largest prime is _3391_
