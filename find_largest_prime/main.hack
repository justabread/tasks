namespace songpush\tasks\find_largest_prime;

use namespace HH\Lib\{IO, Str};
use function exit;

<<__EntryPoint>>
async function main_async(): Awaitable<noreturn> {
  $tests = vec<(vec<vec<int>>, int)>[
    tuple(
      vec[
        vec[4, 0, 2, 0, 3, 4],
        vec[4, 0, 4, 2, 9, 6],
        vec[8, 1, 6, 1, 7, 6],
        vec[2, 5, 1, 7, 7, 8],
        vec[5, 6, 8, 8, 4, 6],
        vec[5, 9, 5, 6, 3, 5],
      ],
      4482569563,
    ),
    tuple(
      vec[
        vec[2, 7, 6, 2, 5, 4],
        vec[1, 1, 0, 7, 8, 1],
        vec[7, 2, 1, 7, 3, 5],
        vec[0, 5, 4, 9, 8, 9],
        vec[0, 5, 9, 9, 0, 6],
        vec[8, 7, 1, 2, 8, 7],
      ],
      27627798067,
    ),
    tuple(
      vec[
        vec[0, 0, 0, 2, 9],
        vec[0, 1, 8, 5, 3],
        vec[5, 3, 4, 4, 6],
        vec[3, 2, 0, 0, 5],
        vec[5, 5, 5, 8, 8],
      ],
      853,
    ),
    tuple(
      vec[
        vec[5, 7, 8],
        vec[5, 0, 3],
        vec[0, 9, 1],
        vec[6, 6, 2],
      ],
      5783,
    ),
    tuple(
      vec[
        vec[9, 5, 0, 2, 1, 4],
        vec[3, 4, 0, 8, 2, 8],
      ],
      3,
    ),
  ];

  $exitCode = 0;

  foreach ($tests as $testIdx => list($matrix, $largest)) {
    $result = get_largest_prime($matrix);

    if ($result === $largest) {
      await IO\request_output()->writeAllAsync(
        Str\format("test#%d Success\n", $testIdx),
      );
    } else {
      await IO\request_errorx()->writeAllAsync(
        Str\format(
          "Fail test#%d. Your result is: %d. Expected: %d\n",
          $testIdx,
          $result,
          $largest,
        ),
      );
      ++$exitCode;
    }
  }

  exit($exitCode);
}

function get_largest_prime(vec<vec<int>> $matrix)[]: int {
  // IMPLEMENT ME
  return -1;
}
