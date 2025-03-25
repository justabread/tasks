# Get primes product

## task

Find all of the unique prime numbers in the matrix. In matrix you can move **right**, **left**, **up**, **down**
and **diagonals**, starting by any cell.

One index usable only once time for create a number

## Constraints

The matrix dimensions is `MxN`\
where 1 &lt;= `N` &lt;= 4 \
and 1 &lt;=`M` &lt;= 4

and each number in the matrix is 0 =&lt; **M**<sub>mn</sub> =&lt; 9

the **modulo** is `2718281`

## Example

let this matrix = **M** (2x2)

|       | **1** | **2** |
| :---- | :---: | ----: |
| **1** |  _2_  |   _3_ |
| **2** |  _2_  |   _9_ |

primes are

- 2 =&gt; **M**<sub>11</sub>
- 3 =&gt; **M**<sub>12</sub>
- 23 =&gt; **M**<sub>11</sub>x10 + **M**<sub>12</sub>
- 29 =&gt; **M**<sub>11</sub>x10 + **M**<sub>22</sub>
- 223 =&gt; **M**<sub>11</sub>x10<sup>2</sup> + **M**<sub>21</sub>x10 + **M**<sub>12</sub>
- 229 =&gt; **M**<sub>11</sub>x10<sup>2</sup> + **M**<sub>21</sub>x10 + **M**<sub>22</sub>
- 239 =&gt; **M**<sub>11</sub>x10<sup>2</sup> + **M**<sub>12</sub>x10 + **M**<sub>22</sub>
- 293 =&gt; **M**<sub>11</sub>x10<sup>2</sup> + **M**<sub>22</sub>x10 + **M**<sub>12</sub>
- 2239 =&gt; **M**<sub>11</sub>x10<sup>3</sup> + **M**<sub>21</sub>x10<sup>2</sup> + **M**<sub>21</sub>x10 + **M**<sub>22</sub>
- 2293 =&gt; **M**<sub>11</sub>x10<sup>3</sup> + **M**<sub>21</sub>x10<sup>2</sup> + **M**<sub>22</sub>x10 + **M**<sub>21</sub>
- 3229 =&gt; **M**<sub>12</sub>x10<sup>3</sup> + **M**<sub>11</sub>x10<sup>2</sup> + **M**<sub>21</sub>x10 + **M**<sub>22</sub>

Then we multiply these primes and apply the **modulo**.
The result is _656.200_
