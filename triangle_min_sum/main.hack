namespace songpush\tasks\triangle_min_sum;

use namespace HH\Lib\{IO, Str};
use function exit;

<<__EntryPoint>>
async function main_async(): Awaitable<noreturn> {
  $tests = vec<int>[542, 554, 581, 516, 3257, 6573];
  $exitCode = 0;

  foreach ($tests as $testIdx => $expected) {
    $result = await get_minimum_path_sum_async(
      Str\format('%s/%d.dat', __DIR__, $testIdx),
    );

    if ($result === $expected) {
      await IO\request_output()->writeAllAsync(
        Str\format("test#%d Success\n", $testIdx),
      );
    } else {
      await IO\request_errorx()->writeAllAsync(
        Str\format(
          "Fail test#%d. Your result is: %d. Expected: %d\n",
          $testIdx,
          $result,
          $expected,
        ),
      );
      ++$exitCode;
    }
  }

  exit($exitCode);
}

async function get_minimum_path_sum_async(string $file): Awaitable<int> {
  // IMPLEMENT ME
  return -1;
}
