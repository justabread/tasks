namespace songpushTest;

<<__EntryPoint>>
async function main_async(): Awaitable<noreturn> {
  require_once __DIR__.'/../vendor/autoload.hack';
  \Facebook\AutoloadMap\initialize();

  $request = \Usox\HackTTP\create_server_request_from_globals();
  await Server::respondToAsync($request);

  exit(0);
}
