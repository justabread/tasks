namespace songpushTest;

//Ez volt a negyedik feladat amit megoldottam, a leghosszabb és legélvezetesebb is egyben. Rájönni magára, hogy hogyan működik a szerver
//és aztán ehhez hozzákötni az én endpointjaimat izgalmas volt, még ha néha azért bonyolult is (session persistent age restriction felülírás)
//
//Itt már megemlítem, hogy a feladatok elkezdésekor készítettem egy ubuntu installációt a gépemen, mert ezt a feladatot mindenképpen hack-ben
//kellett megoldani, a hhvm és vscode integráció sikeres volt, még úgy is, hogy az xOR feladatot intellisense nélkül csináltam meg, mert nem tudtam
//még, hogy vscode-nak abban a mappában kell lennie ahol a .hhconfig van hogy rendesen működjön a vshode-hack extension. A szervert docker-rel tudtam
//futtatni, szerencsére így az environment setup nem vett el sok időt. Az endpointokat Thunder Client extensionnel teszteltem, és így hogy ennél
//a feladatnál nem találtam explicit test case-eket megpróbáltam manuálisan lefedni minden edge-case-t amit tudtam. 

<<__EntryPoint>>
async function main_async(): Awaitable<noreturn> {
  require_once __DIR__.'/../vendor/autoload.hack';
  \Facebook\AutoloadMap\initialize();

  $request = \Usox\HackTTP\create_server_request_from_globals();
  await Server::respondToAsync($request);

  exit(0);
}
