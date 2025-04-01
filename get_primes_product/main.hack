namespace songpush\tasks\get_primes_product;

//Ez lett volna eredetileg a második feladat amit meg akartam oldani, de nem jöttem rá hirtelen hogyan induljak el vele miután végeztem
//a find_largest_prime-mal, mert ugyan azzal az iteratív módszerrel próbálkoztam mint annál a feladatnál. A rest-api után újult erővel
//kezdtem neki és itt már rekurzív megközelítéssel ki tudtam dolgozni egy működő megoldást. Egészen addig, amíg el nem értem a negyedik
//mátrixig a tesztben, ahol a program másfél óra futás után sem talált megfelelő megoldást ami után utána kellett néznem, hogy hol tudjam 
//optimalizálni a futást. Ekkor implementáltam az új prime ellenőrző algoritmust amit részletesen kifejtek a függvény definíciónál.

//Összességében 1 hét kellett a feladatok megoldására, a rest-api-ig 1 feladat/nap a rest-api maga pedig 3-4 napot vett igénybe. Nem voltak
//egyszerűek, sok helyen éreztem úgy, hogy nem fogok tudni kitalálni jó megoldást de így a végén pozitív élménynek könyveltem el (még az 
//xOR feladat 5. test case-ét is).

use namespace HH\Lib\{C, IO, Str};
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

// function checkPrime(int $num): bool {
//   //Először megnézem hogy a szám kisebb-e mint 2. Ha kettőnél kisebb akkor rögtön hamis értékkel térek vissza, mert 
//   //1. Negatív prímszám nem létezik
//   //2. A 0 és az 1 nem prímszám
//   if ($num < 2) {
//     return false;
//   }

//   //Ha a szám nagyobb mint 1, akkor 2-től a számig terjedő értékeken végig iterálok és ellenőrzöm hogy a szám osztható-e ezekkel az értékekkel.
//   //Ha igen, akkor a szám nem prímszám.
//   //Csak a számig megyek a ciklusban, mert bármely a számnál nagyobb érték nem eredményezne egész számot az osztásban (Minden prímszám egész szám).
//   for ($i = 2; $i < $num; $i++) {
//     if ($num % $i == 0) {
//       return false;
//     }
//   }

//   return true;
// }

//Sajnos teljesen újra kellett írnom az előző prím ellenőrző algoritmust mert órákig tartott a program futása. Átfogóbb utánanézés után
//találtam egy optimizált megoldást amit lefordítottam hack-re és implementáltam ebbe megoldásba
function checkPrime(int $num): bool {
  //Ide bevezettem több checket, azon kívül, hogy a szám kisebb mint 2
  if ($num < 2){
    return false;
  }
  //Ha a szám 2 akkor prím
  if ($num == 2) {
    return true;
  } 
  //ha a szám osztható 2-vel akkor biztos nem prím
  if ($num % 2 == 0) {
    return false;
  }

  //A régi megoldással szemben itt csak a keresett szám gyökéig + 1 megyünk (+1 azért mert elhal ha csak gyökig megyek kerekítés miatt)
  //Ezt ezzel a példával értettem meg (36)
  //1 * 36
  //2 * 18
  //3 * 12
  //4 * 9
  //6 * 6 - innentől elkezdve lefelé a tényezők ugyan azok csak fordítva
  //9 * 4
  //12 * 3
  //18 * 2
  //36 * 1

  //tehát ahelyett, hogy 2->36-ig minden számot ellenőrzök, hogy osztahtó-e 36-al, sqrt(36)=6-ig megyek, mert 6 után már csak a tükörképét kapnám
  //az osztásoknak
  $sqrt = (int)\sqrt((float)$num) + 1;
  for ($i = 2; $i < $sqrt; $i++) {
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
): vec<int> {
  $visited[$i][$j] = true;
  $newValue = $currentValue * 10 + $matrix[$i][$j];
  $primes = vec[];

  //Leellenőrzöm, hogy az éppen talált szám prím-e és ha igen, hozzáfűzöm a talált prímekhez
  if (checkPrime($newValue)) {
    $primes[] = $newValue;
  }

  //Előre megadom mind a nyolc irányvektort ami a 0,0 ponttól vett összes irányt fogja tárolni
  $directions = vec[
    vec[-1, -1],
    vec[-1, 0],
    vec[-1, 1],
    vec[0, -1],
    vec[0, 1],
    vec[1, -1],
    vec[1, 0],
    vec[1, 1],
  ];

  //Leellenőrzöm az összes szomszédot minden irányban
  foreach ($directions as $dir) {
    $iDir = $i + $dir[0];
    $jDir = $j + $dir[1];

    //HA
    //az i irány nem ér ki a mátrix sorának valid értékei közül ÉS
    //a j irány nem ér ki a mátrix sorai számának valid értékei közül ÉS
    //nem jártunk még az éppen vizsgált indexen
    if (
      $iDir >= 0 &&
      $iDir < $rows &&
      $jDir >= 0 &&
      $jDir < $cols &&
      !$visited[$iDir][$jDir]
    ) {
      //Elindítok egy újabb mélységi keresést az éppen vizsgált pontból rekurzívan
      $foundPrimes = searchMatrixFromPoint(
        $iDir,
        $jDir,
        $matrix,
        $visited,
        $newValue,
        $rows,
        $cols,
      );

      //Hozzáfűzöm a talált prímeket az összes talált prímhez
      foreach ($foundPrimes as $prime) {
        $primes[] = $prime;
      }
    }
  }

  //Visszatérek a talált prímekkel ha már nem tudok több irányba menni
  return $primes;
}

function get_primes_product(vec<vec<int>> $matrix): int {
  $rows = C\count($matrix);
  $cols = C\count($matrix[0]);

  $allFoundPrimes = vec[];

  //Elindítom a rekurzív mélységi keresést a mátrix minden cellájából
  for ($i = 0; $i < $rows; $i++) {
    for ($j = 0; $j < $cols; $j++) {
      //Előkészítem a bejárt pontok tárolóját minden pont ciklusánál
      $visited = vec[];
      for ($k = 0; $k < $rows; $k++) {
        $visited[] = vec[];
        for ($l = 0; $l < $cols; $l++) {
          $visited[$k][] = false;
        }
      }

      //Innen indul a mélységi keresés
      $currentCellPrimes =
        searchMatrixFromPoint($i, $j, $matrix, $visited, 0, $rows, $cols);

      //Ha véget ért a pontbóli mélységi keresés akkor hozzáfűzöm a pontból talált prímeket az összes prímhez
      foreach ($currentCellPrimes as $prime) {
        $allFoundPrimes[] = $prime;
      }
    }
  }

  //Kitörlöm a tárolóból a duplikált prímeket
  $sanitizedPrimes = \array_unique($allFoundPrimes);

  //Összeszorzom a prímeket és applikálom a modulót
  $product = 1;
  $modulo = 2718281;

  foreach ($sanitizedPrimes as $prime) {
    $product = ($product * $prime) % $modulo;
  }

  return $product;
}
