namespace songpushTest;

use namespace HH\Lib\{SecureRandom, Str};
use function apc_fetch;
use function apc_store;

final class Session {
  private function __construct(
    private int $id,
    private bool $logged,
    private ?string $token,
    private bool $canViewAgeRestricted = false,
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

  public function getCanViewAgeRestricted()[]: bool {
    return $this->canViewAgeRestricted;
  }

  public function setCanViewAgeRestricted(bool $canViewAgeRestricted): void {
    $this->canViewAgeRestricted = $canViewAgeRestricted;
  }

  public static async function loadAsync(string $token): Awaitable<this> {
    //beolvasom session usert a token-hez tárolt age restriction override-dal

    $_success = null;
    $result =
      apc_fetch(Str\format('%s/cache/%s', __FILE__, $token), inout $_success);

    $_ageRestSuccess = null;
    $canViewAgeRestrictedResult = apc_fetch(
      Str\format('%s/cache/%s', __FILE__, $token.'a'),
      inout $_ageRestSuccess,
    );

    if ($result !== false) {
      return new self($result, true, $token, $canViewAgeRestrictedResult);
    }

    return new self(0, false, null, false);
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

  //Eltárolom az age restriction override értékét cache-ben hogy megmaradjon requestek között
  public static async function updateAgeRestrictionAsync(
    string $token,
    bool $canViewAgeRestricted,
  ): Awaitable<void> {
    apc_store(
      Str\format('%s/cache/%s', __FILE__, $token.'a'),
      $canViewAgeRestricted,
      600,
    );
  }
}
