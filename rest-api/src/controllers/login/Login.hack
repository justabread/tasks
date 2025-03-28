namespace songpushTest\controllers\login;

use namespace HH\Lib\{C, Vec};
use namespace songpushTest\{controllers, datas, models};
use type songpushTest\Session;
use function json_decode;
use function sha1;

final class Login extends controllers\Controller {
  const type TResponseModel = models\Login;

  <<__LateInit>> private datas\user\User $user;

  <<__Override>>
  protected async function doAsync(): Awaitable<this::TResponseModel> {
    $session = await Session::createAsync($this->user);

    return new models\Login($session->getToken() as nonnull);
  }

  <<__Override>>
  protected async function checkPermssionsAsync(): Awaitable<bool> {
    $rawRequest = await $this->getRequest()->getBody()->readAllAsync();
    $requestBody = json_decode($rawRequest, true);

    if ($requestBody === null) {
      return false;
    }

    $nickname = $requestBody['nickname'] ?? null;
    $password = $requestBody['password'] ?? null;

    if ($nickname === null || $password === null) {
      return false;
    }

    $hash = sha1($password);

    $user = Vec\filter(
      datas\user\Users::getValues(),
      $user ==>
        $user->getNickName() === $nickname && $user->isMinePassword($hash),
    )
      |> C\first($$);

    if ($user !== null) {
      $this->user = $user;

      return true;
    }

    return false;
  }
}
