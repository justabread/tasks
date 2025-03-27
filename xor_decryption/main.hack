namespace songpush\tasks\xor_decrypt;

use namespace HH\Lib\{IO, Str, Vec, C, File, Regex};
use function base64_decode;
use function base64_encode;
use function exit;
use function hash;

<<__EntryPoint>>
async function main_async(): Awaitable<void> {
  $tests = vec[
    tuple(
      'HzsuYSY6JSgmJiZhPDo/KS8hKjYqP2sgJjw+Lz9zIjJrYnthDgYZb2sSOGE4PCQvazI4YTI8PmE5NioiIzYvYSpzKDMuNyI1azw'.
      'tYSY8OSRrJyMgJXN6cWsWHhNncz8pLnMqLCQmJTVrJCItJ3MpJGsnOSAlIC0kOSEuJWsnJGE/Oy5hKTIlKmsyKCIkJiU1ayokNG'.
      's7KjcuczszJCUiJS43ayA/cz8pLnMpJCw6JS8iPSxhJDVrNSM2ay8uKz9hJjwlNSN9',
      'b7a2b8afdcebef7387b1752fb3a0b0d5b05b76c84c353a08764cb101135f036e68b414ea4fd97dca01e8267c52f1166326f'.
      'fc8141a5490e5c48a3da68ebdfb10',
    ),
    tuple(
      'HyssNBwxMTtsJS4/IzMxcy82JzI4KzAgbCsscxgtKQcjL2J7LSomcz8rLT1sDSwgOCUlIS0pa3M4K2I2LTYscyErLDY1ZDU6OCxi'.
      'Pjk3KzBsNC4yLyEvNiIwMX1sHS0mbCcjPWw3JzZsPS0mPmQyMjUpJz04ZDI2PmQhISklNjojKmI6IiArJSUgNzIgKDtzKiswcykl'.
      'ITtsJyM+PCUrNCJkKz1sMyo6LyxiKiMxYiMtNjY6Ly0yMjghY3MNIjY2PmQhISklNjoiI2IqIzEwcx8rLDQcMTE7bCUhMCMxLCdg'.
      'ZDs8OWQhMiJkMTYgISEnbCUsKmw3LSYiIGI8ImQ2OylkMj8tMCQ8PilscwUiYiojMWI/JS8ncy1kMTw5KiZ/bD0tJmwsIyUpZDY7'.
      'KWQtIzgtLT1sMC1zLzYnMjghYjJsECs4GCspczotJjYjZDU6OCxiJyQhYiEpNzI2LzArJSlkMTw5KiZzLSomcz8xID4lMGI6OGQ1'.
      'OjgsKz1sdnZzJCs3IT9qYhoqZDY7KWQ0OighLXMhIScnP2QtJj5kJSYlICc/JSonIGBkOzw5ZDU6IChiMSlkMjIlIGIyKjAnIWwl'.
      'YiAkKzAnbDArPilq',
      '908359412a55f83d881851d5b73b056beae370217b7c331efdbc6dcac1bad0a9fcf0a7f106160cfe8fd769d4615f56755c56'.
      '28d5cd64744e6085d808c834b59a',
    ),
    tuple(
      'EDcrMjErcyYvPjUvOiIgc2NuICA6cyc7NyIrJ2VzbWUIOjc9J2luJy0rczYhJisqczEmMjFuMik8NiQqKmUrKyw9JzZuPCtuByw'.
      'lByolcyYvPWUsNmUjMiErcyQ4MiwiMiciNmUhPWUdPCspAzA9O2U5OyAgcyY8NiQ6OispcyYvPjUvOiIgIGtuEiM6NjduICA6Jy'.
      'wgNGUvcyYvPjUvOiIgcyc7NyIrJ2luJy0rczYhJisqcyw9czMnICwsPyBuJypuIDAnJyQsPyBuMDcrMjEhITZuPCtuACogNBU7I'.
      'C1gcwIrJ2UtISAvJywhPTZubntuEDcrMjEhITZuMCQgcyshJGUtPyQnPmU+Mjc6cyooczEmNmUsJiEpNjFuMisqczY7MSgnJ2U6'.
      'OyAnIWUaOi4aPC5uJSwqNio9c20tISAvJywhPTZnczInJy1uJy0rczYhJisqcyooczEmNmUtMig+MiwpPWtuBy0rcyI8NiQ6Njd'.
      'uJy0rOjduISAvMC1uPDduMjMrISQpNmU4OiA5IGluJy0rcy0nNC0rIWU6OyBuMighJis6czEmMjFuMCQgcycrczcrICA8JSAqcy'.
      'M8PChuJy0rcyc7NyIrJ2tuEikiczY7MSgnJzErN2UtISAvJywhPTZuMCQgcycrczMnNjIrN2UnPWUvcyYiNiQ8cyYvPjUvOiIgc'.
      'yEvIC0sPCQ8N2tuETxuJy0rczIvKn9uEDcrMjEnPCs9czInJy1uMmU9JzchPSJuJisqNjc+NjcoPDcjMistNmUvISBuPSo6cycn'.
      'PykrN2RuGjFuOjZuMik9PGU+PDY9OiciNmU6PGU8NjUhITFuMDcrMjEnPCs9cywoczEmNjxuJSwhPyQ6NmUhJjduNDAnNyAiOis'.
      'rIGtuEisvPzw6OiY9c2NuASA+PDc6Oispc3hwcwQiISAvNzxuNzA8OispczEmNmUtMig+MiwpPWluJy0rczUrISMhISgvPSYrcy'.
      'ooczEmNmUtISAvJywhPTZuMCQgcycrczYrNituOituJy0rc2cPPSQiKjEnMDZsczEvMWtuBy0rcyghIDFuOig+PDc6Mis6cw4eG'.
      'jZiczY7MC1uMjZuJyo6MiluJSwrJDZuPDduPywlNjZuPCNuJy0rcyY8NiQ6OiogIGU5OjEmczwhJjduICo7PSFicyQ8NmUqOjY+'.
      'PyQ3NiFuOyA8NmtuACohPWluOjFuJCwiP2UsNmU+PDY9OiciNmU6PGUqPDIgPyovN2UvczcrIyo8J2UvIGUvcxUKFWUoOikrcyE'.
      'nISAtJyk3cyM8PChuKio7IWUqMjYmMSovISFg',
      'c73d658734140e1f5762e05ecca7d7746f744eb9a046095bb2bdbf331d87b22d545f9062a97a3a3dbf83f12b156b63face2'.
      'e9e508f9b3f58e40359e4c2ba4d68',
    ),
    tuple(
      'Gz8mNxglOzhoMSQ8Jyc7cCsiLTE8PzojaD8mcBw5IwQnO2h4KT4scDs/Jz5oGSYjPDEvIik9YXA8P2g1KSImcCU/JjUxcD85PDh'.
      'oPT0jITNoICQxKzUlNSYkO35oCSclaDMpPmgjLTVoKSclOnA4MTE9LT48cDg1OnArIi0xPDknPmg5JjQhJiE0PTEkPDFwLj86cC'.
      '0xKzhoMyk9ODEhNyZwIT5oJyA5KzhoKSclaCApIjw5Kzk4MTw1aXAJNjw1OnArIi0xPDkmN2gpJyU6cBs/JjcYJTs4aDErMyclJ'.
      'iRkcDE/PXArMSZwOzUkNSskaDEmKWgjJyUmNGg/JnA8OC1wODwpJC4/Oj1mcAE2aCknJWg8ITstcClwOz89Pix8aCknJWg4KSYt'.
      'cDw4LXAnIDw5Jz5oJCdwKyItMTw1aDFoBCE7HD8jcD45LDUncD85PDhoJCA1aCItIzg1KyQhJi1wOz89PixwKT4scDslKj0hJGg'.
      '5PHA/OTw4IT5oYnxwID89Ijt+aBkucDw4LXA+OSw1J3AlNS0kO3AnJTpwLyUhNC08IT4tI2RwMT89cD85JDxoMi1wODEhNGgxLi'.
      'QtImgxaCMgPzokaCQhPS1+',
      '908359412a55f83d881851d5b73b056beae370217b7c331efdbc6dcac1bad0a9fcf0a7f106160cfe8fd769d4615f56755c5'.
      '628d5cd64744e6085d808c834b59a',
    ),
    tuple(
      'Ejg9NzthMSA3YjU/JjZiMjIhMScvNCplLTN3Oy0nYTwqPG5hHm8uLC4gY2UrNXc4JDFhNm8nKzV3KjMrLXtvJzc1dwZlKi4nKml'.
      'iODg6ZScvPSA8JyV3IDdiICUqZScvPSA8Ky8wbzEqJHc7JDEqJGEaHR4IEBplBRgBYhV3CAwXEm8QEXtvLCd3Nio0dykqNDkrZT'.
      'U/JjZhPCo8bXc2KjR3OCwtO28jKDkrZTU/KmUyOCMwNT4gK2EjICpv',
      '60a8d72d57d96733a6dc888a153804013cbb0a2b72a2b49a7533d1e56fda88449a2ca8587ca7b68ef93105eba9b6a7121eb'.
      '36b6d364ed5baeb07ca6b7d038248',
    ),
  ];

  // $encrypted = tuple(
  //     'Ejg9NzthMSA3YjU/JjZiMjIhMScvNCplLTN3Oy0nYTwqPG5hHm8uLC4gY2UrNXc4JDFhNm8nKzV3KjMrLXtvJzc1dwZlKi4nKml'.
  //     'iODg6ZScvPSA8JyV3IDdiICUqZScvPSA8Ky8wbzEqJHc7JDEqJGEaHR4IEBplBRgBYhV3CAwXEm8QEXtvLCd3Nio0dykqNDkrZT'.
  //     'U/JjZhPCo8bXc2KjR3OCwtO28jKDkrZTU/KmUyOCMwNT4gK2EjICpv',
  //     '60a8d72d57d96733a6dc888a153804013cbb0a2b72a2b49a7533d1e56fda88449a2ca8587ca7b68ef93105eba9b6a7121eb'.
  //     '36b6d364ed5baeb07ca6b7d038248',
  //   )
  // ;

  // $encrypted = tuple(
  //     'Gz8mNxglOzhoMSQ8Jyc7cCsiLTE8PzojaD8mcBw5IwQnO2h4KT4scDs/Jz5oGSYjPDEvIik9YXA8P2g1KSImcCU/JjUxcD85PDh'.
  //     'oPT0jITNoICQxKzUlNSYkO35oCSclaDMpPmgjLTVoKSclOnA4MTE9LT48cDg1OnArIi0xPDknPmg5JjQhJiE0PTEkPDFwLj86cC'.
  //     '0xKzhoMyk9ODEhNyZwIT5oJyA5KzhoKSclaCApIjw5Kzk4MTw1aXAJNjw1OnArIi0xPDkmN2gpJyU6cBs/JjcYJTs4aDErMyclJ'.
  //     'iRkcDE/PXArMSZwOzUkNSskaDEmKWgjJyUmNGg/JnA8OC1wODwpJC4/Oj1mcAE2aCknJWg8ITstcClwOz89Pix8aCknJWg4KSYt'.
  //     'cDw4LXAnIDw5Jz5oJCdwKyItMTw1aDFoBCE7HD8jcD45LDUncD85PDhoJCA1aCItIzg1KyQhJi1wOz89PixwKT4scDslKj0hJGg'.
  //     '5PHA/OTw4IT5oYnxwID89Ijt+aBkucDw4LXA+OSw1J3AlNS0kO3AnJTpwLyUhNC08IT4tI2RwMT89cD85JDxoMi1wODEhNGgxLi'.
  //     'QtImgxaCMgPzokaCQhPS1+',
  //     '908359412a55f83d881851d5b73b056beae370217b7c331efdbc6dcac1bad0a9fcf0a7f106160cfe8fd769d4615f56755c5'.
  //     '628d5cd64744e6085d808c834b59a',
  //   )
  // ;

  

  $exitCode = 0;

  // list($input, $hash) = $encrypted;

  // $decoded = base64_decode($input);

  // $decryptedInputs = decrypt($decoded);


  // if(C\count($decryptedInputs) > 0) {
  //   for($i = 0; $i < C\count($decryptedInputs); $i++){
  //     echo $decryptedInputs[$i] . "\n";
  //   }
  // }

  // $key = "KULCS";
  // $encrypted = xOR('VGhpcyBpcyBhIHRlc3QgZW5nbGlzaCBzZW50ZW5jZS4=', $key);
  // echo $encrypted . "\n";
  // $decrypted = xOR($encrypted, $key);
  // echo base64_decode($decrypted) . "\n";


  // await IO\request_output()->writeAllAsync($encrypted);

  // $decrypted = xOR($encrypted, $key);

  // await IO\request_output()->writeAllAsync($decrypted);



  foreach ($tests as $testIdx => list($encrypted, $hash)) {
    $decrypted = decrypt(base64_decode($encrypted));
    if (Str\compare(hash('sha512', $decrypted), $hash) === 0) {
      await IO\request_output()->writeAllAsync(
        Str\format("test#%d Success\n", $testIdx),
      );
    } else {
      await IO\request_errorx()->writeAllAsync(
        Str\format("Fail test#%d. Your result is: %s\n", $testIdx, $decrypted),
      );
      ++$exitCode;
    }
  }

  exit($exitCode);
}

function xOR(string $input, string $key): string {
  $output = "";
  $keyLength = Str\length($key);
  
  //Végig iterálok a szövegen
  for ($i = 0; $i < Str\length($input); $i++) {
      //Minden egyes iterációnál hozzáfűzöm az output-hoz
      //a bemeneti szöveg éppeni karakterére applikált kulcs értéket
      //az xor bitművelettel.

      //A kulcson úgy iterálok, hogy veszem az kulcs hosszúságát
      //és megnézem azt osztási maradékot az éppeni ciklus számával.
      //Ez azt fogja eredményezni, hogy a kulcs visszafordul 0-ra ha a végére
      //értünk de a bemeneti szövegből még vannak hátra karakterek.
      $output .= $input[$i] ^ $key[$i % $keyLength];
  }
    
  return $output;
}

function generateKeys(): vec<string> {
  $alphabet = vec["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
  $allKeys = vec[];

  //Legenerálom az 1, 2, 3 és 4 jegyű kulcsokat (összesen 475254)
  for($i = 0; $i < C\count($alphabet); $i++) {
    $allKeys[] = $alphabet[$i];
  }

  for($i = 0; $i < C\count($alphabet); $i++){
    for($j = 0; $j < C\count($alphabet); $j++){
      $allKeys[] = $alphabet[$i].$alphabet[$j];
    }
  }

  for($i = 0; $i < C\count($alphabet); $i++){
    for($j = 0; $j < C\count($alphabet); $j++){
      for($k = 0; $k < C\count($alphabet); $k++){
        $allKeys[] = $alphabet[$i].$alphabet[$j].$alphabet[$k];
      } 
    }
  }

  for($i = 0; $i < C\count($alphabet); $i++){
    for($j = 0; $j < C\count($alphabet); $j++){
      for($k = 0; $k < C\count($alphabet); $k++){
        for($l = 0; $l < C\count($alphabet); $l++){
          $allKeys[] = $alphabet[$i].$alphabet[$j].$alphabet[$k].$alphabet[$l];
        }
      } 
    }
  }

  return $allKeys;
}

function getCommonWords(): vec<string> {
  $commonWords = vec[];
  $file = \fopen(__DIR__.'/commonEnglish.dat', 'r');
  if ($file === false) {
      return vec[];
  }
  
  try {
      while (($line = \fgets($file)) !== false) {
          $commonWords[] = \trim($line);
      }
      return $commonWords;
  } finally {
      \fclose($file);
  }
}

function checkEnglish(string $rawInput, vec<string> $commonWords): bool {
  $isLikelyEnglish = false;
  

  //Kisbetűs formátumra teszem a bemeneti szöveget ;s eltűntetem a pontot a mondat végéről
  $input = Str\lowercase($rawInput);
  $input = Str\strip_suffix($input, ".");
  
  $found = 0;
  
  //Leellenőrzöm hogy van e bármilyen gyakori angol szó a bemeneti string-ben
  $inputWords = Str\split($input, ' ');

  foreach ($commonWords as $englishWord) {
    foreach ($inputWords as $currentWord) {
      if ($currentWord === $englishWord) {
          $found++;
      }
    }
  }

  
  //A magán és mássalhangzókat ellenőrző regex-el megszámolom hány magán és mássalhangzó van a szövegben
  $vowels = \preg_match_all('/[aeiou]/', $input);
  $consonants = \preg_match_all('/[bcdfghjklmnpqrstvwxyz]/', $input);

  $vowelRatio = 0;

  if($consonants > 0) {
    $vowelRatio = $vowels / $consonants;
  }

  //Hogyha több mint egy hasonló szót talált és a magánhangzók/mássalhangzók aránya 0.3 és 3 között van akkor
  //valószínűleg helyes angol mondatot találtunk
  //&&($vowelRatio >= 0.3 && $vowelRatio <= 3.0)
  if(($found > 6) && ($vowelRatio >= 0.3 && $vowelRatio <= 1.5)) {
    $isLikelyEnglish = true;
  }

  return $isLikelyEnglish;
}

function decrypt(string $input): string {
  $commonWords = getCommonWords();
  $keys = generateKeys();

  $result = "";

  foreach($keys as $key) {
    $decrypted = xOR($input, $key);

    
    $isLikelyEnglish = checkEnglish($decrypted, $commonWords);

    if($isLikelyEnglish){
      $result = $decrypted;
    }
  }

  // $file = File\open_write_only(__DIR__.'/results.dat');

  // foreach($keys as $key) {
  //   $decrypted = xOR($input, $key);
  //   //$file->writeAllAsync($decrypted . "\n" . $key . "\n");
  //   // $file->writeAllAsync($key . "\n");
    
  //   $isLikelyEnglish = checkEnglish($decrypted, $commonWords);

  //   if($isLikelyEnglish){
  //     $file->writeAllAsync($decrypted . "\n" . $key . "\n");
  //   }
  // }


  // $file->close();
  

  return $result;
}
