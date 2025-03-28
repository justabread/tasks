namespace songpushTest;

use namespace HH\Lib\{SecureRandom, Str};
use function apc_fetch;
use function apc_store;

final class Session {
  private function __construct(
    private int $id,
    private bool $logged,
    private ?string $token,
  )[] {
  }

  public function getId()[]: int {
    return $this->id;
  }

  public function isLogged()[]: bool {
    return $this->logged;
  }

  public function getToken()[]: ?string {
    return $this->token;
  }

  public static async function loadAsync(string $token): Awaitable<this> {
    $_success = null;
    $result =
      apc_fetch(Str\format('%s/cache/%s', __FILE__, $token), inout $_success);

    if ($result !== false) {
      return new self($result, true, $token);
    }

    return new self(0, false, null);
  }

  public static async function createAsync(
    datas\user\User $user,
  ): Awaitable<this> {
    do {
      $token = SecureRandom\string(30, 'abcdefghijklmnopqrstuvwxyz');
      // HHAST_IGNORE_ERROR[DontAwaitInALoop]
      $session = await static::loadAsync($token);
    } while ($session->logged || $session->getToken() !== null);

    apc_store(Str\format('%s/cache/%s', __FILE__, $token), $user->getId(), 600);

    return new self($user->getId(), true, $token);
  }
}
