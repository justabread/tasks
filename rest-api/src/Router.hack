namespace songpushTest;

use namespace Facebook\HackRouter;

final class Router
  extends HackRouter\BaseRouter<classname<controllers\Controller>> {
  <<__Override>>
  public function getRoutes(): ImmMap<
    HackRouter\HttpMethod,
    ImmMap<string, classname<controllers\Controller>>,
  > {
    return ImmMap {
      HackRouter\HttpMethod::POST => ImmMap {
        '/login' => controllers\login\Login::class,
      },
      HackRouter\HttpMethod::GET => ImmMap {
        '/me' => controllers\me\Me::class,
      },
    };
  }
}
