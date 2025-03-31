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
        '/user/{id}' => controllers\user\UserById::class,
        '/user' => controllers\user\UsersByParams::class,
        '/media/{id}' => controllers\login\MediaById::class,
        '/media' => controllers\media\MediasByParams::class,
      },
      HackRouter\HttpMethod::PUT => ImmMap {
        '/enable' => controllers\ageRestricted\Enable::class,
      },
      HackRouter\HttpMethod::DELETE => ImmMap {
        '/disable' => controllers\ageRestricted\Disable::class,
      },
    };
  }
}
