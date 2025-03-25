namespace songpush\tasks\get_primes_product;

use namespace HH\Lib\{IO, Str};
use function exist;

<<__EntryPoint>>
async function main_async(): Awaitable<noreturn> {
  $tests = vec<(vec<vec<int>>, int)>[
    tuple(vec[vec[2, 3], vec[2, 9]], 656200),
    tuple(vec[vec[6, 7], vec[2, 7], vec[3, 1], vec[2, 2]], 150007),
    tuple(vec[vec[1, 1, 6], vec[1, 2, 4], vec[2, 3, 6]], 2505933),
    tuple(vec[vec[8, 0, 3], vec[6, 0, 9], vec[5, 6, 9], vec[8, 1, 1]], 1426659),
    tuple(vec[vec[5, 5, 9, 2], vec[7, 9, 3, 9], vec[9, 0, 5, 5]], 2161149),
  ];

  $exitCode = 0;

  foreach ($tests as $testIdx => list($matrix, $product)) {
    $result = get_primes_product($matrix);

    if ($result === $product) {
      await IO\request_output()->writeAllAsync(
        Str\format("test#%d Success\n", $testIdx),
      );
    } else {
      await IO\request_errorx()->writeAllAsync(
        Str\format(
          "Fail test#%d. Your result is: %d. Expected: %d\n",
          $testIdx,
          $result,
          $product,
        ),
      );
      ++$exitCode;
    }
  }

  exit($exitCode);
}

function get_primes_product(vec<vec<int>> $matrix)[]: int {
  // IMPLEMENT ME
  return -1;
}
