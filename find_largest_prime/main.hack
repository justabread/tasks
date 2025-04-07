namespace songpush\tasks\find_largest_prime;

use namespace HH\Lib\{C, IO, Str};
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

function checkPrime(int $num)[]: bool {
  if ($num < 2) {
    return false;
  }

  if ($num == 2) {
    return true;
  }

  if ($num % 2 == 0) {
    return false;
  }

  $sqrt = (int)\sqrt((float)$num) + 1;

  //Itt teljesen igazad volt, félrenézés volt az én részemről, itt már háromtól indulok és kettesével lépek, hogy csak páratlan számokat
  //ellenőrizzek
  for ($i = 3; $i < $sqrt; $i += 2) {
    if ($num % $i == 0) {
      return false;
    }
  }
  return true;
}

function searchMatrixFromPoint(
  int $i,
  int $j,
  vec<vec<int>> $matrix,
  vec<vec<bool>> $visited,
  int $currentValue,
  int $rows,
  int $cols,
)[]: vec<int> {
  $visited[$i][$j] = true;
  $newValue = $currentValue * 10 + $matrix[$i][$j];
  $primes = vec[];

  //Ellenőrzöm, Idx(n) = N or Idx(m) = M -nek megfelelően hogy megfelelő helyen van-e és prím szám e a vizsgált érték
  if ((($j == $cols - 1) || ($i == $rows - 1)) && checkPrime($newValue)) {
    $primes[] = $newValue;
  }

  //Itt csak a jobbra és le irányokat vizsgálom ebben a feladatban
  $directions = vec[
    vec[0, 1], //jobbra
    vec[1, 0], //le
  ];

  foreach ($directions as $dir) {
    $iDir = $i + $dir[0];
    $jDir = $j + $dir[1];

    if (
      $iDir >= 0 &&
      $iDir < $rows &&
      $jDir >= 0 &&
      $jDir < $cols &&
      !$visited[$iDir][$jDir]
    ) {
      $foundPrimes = searchMatrixFromPoint(
        $iDir,
        $jDir,
        $matrix,
        $visited,
        $newValue,
        $rows,
        $cols,
      );

      foreach ($foundPrimes as $prime) {
        $primes[] = $prime;
      }
    }
  }

  return $primes;
}

function get_largest_prime(vec<vec<int>> $matrix)[]: int {
  $rows = C\count($matrix);
  $cols = C\count($matrix[0]);

  //Itt keysetre állítottam a típúst a tanácsodnak megfelelően
  $allFoundPrimes = keyset[];

  for ($i = 0; $i < $rows; $i++) {
    for ($j = 0; $j < $cols; $j++) {
      //Hogyha az első sorban vagyunk vagy az első oszlopban, úgy hogy az első utáni sorban
      if ($i == 0 || ($j == 0 && $i > 0)) {
        $visited = vec[];
        for ($k = 0; $k < $rows; $k++) {
          $visited[] = vec[];
          for ($l = 0; $l < $cols; $l++) {
            $visited[$k][] = false;
          }
        }

        $currentCellPrimes =
          searchMatrixFromPoint($i, $j, $matrix, $visited, 0, $rows, $cols);

        //Ha véget ért a pontbóli mélységi keresés akkor hozzáfűzöm a pontból talált prímeket az összes prímhez
        foreach ($currentCellPrimes as $prime) {
          $allFoundPrimes[] = $prime;
        }
      }
    }
  }

  $largestPrime = -1;

  foreach ($allFoundPrimes as $prime) {
    if ($prime > $largestPrime) {
      $largestPrime = $prime;
    }
  }

  return $largestPrime;
}
