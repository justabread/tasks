namespace songpush\tasks\triangle_min_sum;

use namespace HH\Lib\{C, IO, Str};
use function exit;

<<__EntryPoint>>
async function main_async(): Awaitable<noreturn> {
  $tests = vec<int>[542, 554, 581, 516, 3257, 6573];
  $exitCode = 0;

  foreach ($tests as $testIdx => $expected) {

    $result = await get_minimum_path_sum_async(Str\format('/%d.dat', $testIdx));

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

function readTriangle(string $path): vec<vec<int>> {
  $triangle = vec[];

  $file = \fopen(__DIR__.$path, 'r');
  if ($file === false) {
    return vec[];
  }

  try {
    while (($line = \fgets($file)) !== false) {
      $elements = vec[];
      $token = \strtok($line, ",");

      while ($token !== false) {
        $elements[] = (int)\trim($token);
        $token = \strtok(",");
      }

      $triangle[] = $elements;
    }

    return $triangle;
  } finally {
    \fclose($file);
  }
}

class MinPathSum {
  private dict<string, int> $memo = dict[];

  public function getMinSumOfNode(
    vec<int> $currentIndex,
    vec<vec<int>> $triangle,
  ): int {
    //Az éppeni indexet stringesítem 0-0 formátumban
    $key = $currentIndex[0].'-'.$currentIndex[1];

    //Hogyha a kulcs létezik a memóriában akkor visszatérek a memóriában tárolt értékkel, ahelyett hogy elindítok egy keresést belőle
    if (C\contains_key($this->memo, $key)) {
      return $this->memo[$key];
    }

    //Eltárolom az éppen vizsgált értéket
    $currentValue = $triangle[$currentIndex[0]][$currentIndex[1]];

    //Hogyha az utolsó sorban vagyok, akkor visszatérek az éppeni értékkel
    if ($currentIndex[0] === C\count($triangle) - 1) {
      return $currentValue;
    }

    //Eltárolom a bal és jobb oldali gyerek node indexét
    $leftChildIndex = vec[$currentIndex[0] + 1, $currentIndex[1]];
    $rightChildIndex = vec[$currentIndex[0] + 1, $currentIndex[1] + 1];

    //A bal és jobb oldali összeg kiszámítására elindítok egy rekurzív keresést, aminek a visszatérési értékéhez
    //hozzáadom az éppeni értéket és megnézem hogy melyik kisebb
    $leftSum =
      $this->getMinSumOfNode($leftChildIndex, $triangle) + $currentValue;

    $rightSum =
      $this->getMinSumOfNode($rightChildIndex, $triangle) + $currentValue;

    //Eltárolom az éppeni index alatt a memóriában a balos vagy a jobbos összeget és visszatérek vele
    if ($leftSum < $rightSum) {
      $this->memo[$key] = $leftSum;
    } else {
      $this->memo[$key] = $rightSum;
    }

    return $this->memo[$key];
  }
}

//Ez volt az első megoldásom, sajnos az utolsó háromszögre túlságosan lassú, ezért memorizálást kellett bevezetnem,
//hogy felgyorsítsam a futást

// function getMinSumOfNode(vec<int> $currentIndex, vec<vec<int>> $triangle, dict<string, int> $memo): int {
//   $currentValue = $triangle[$currentIndex[0]][$currentIndex[1]];

//   if ($currentIndex[0] === C\count($triangle) - 1) {
//     return $currentValue;
//   }

//   $currentValue = $triangle[$currentIndex[0]][$currentIndex[1]];

//   $leftChildIndex = vec[$currentIndex[0] + 1, $currentIndex[1]];
//   $RightChildIndex = vec[$currentIndex[0] + 1, $currentIndex[1] + 1];

//   $leftSum = getMinSumOfNode($leftChildIndex, $triangle) + $currentValue;
//   $rightSum = getMinSumOfNode($RightChildIndex, $triangle) + $currentValue;

//   if ($leftSum < $rightSum) {
//     return $leftSum;
//   }

//   return $rightSum;

// }

async function get_minimum_path_sum_async(string $file): Awaitable<int> {
  $triangle = readTriangle($file);

  $minPathSumSolver = new MinPathSum();
  $minSum = $minPathSumSolver->getMinSumOfNode(vec[0, 0], $triangle);

  return $minSum;
}
