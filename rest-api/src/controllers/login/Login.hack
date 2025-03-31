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
  protected async function checkPermssionsAsync(
  ): Awaitable<controllers\CheckPermssionsReturn> {
    $rawRequest = await $this->getRequest()->getBody()->readAllAsync();
    $requestBody = json_decode($rawRequest, true);

    if ($requestBody === null) {
      return new controllers\CheckPermssionsReturn(
        false,
        'No request body was provided.',
      );
    }

    $nickname = $requestBody['nickname'] ?? null;
    $password = $requestBody['password'] ?? null;

    if ($nickname === null || $password === null) {
      return new controllers\CheckPermssionsReturn(
        false,
        'The nickMame and/or password was not provided',
      );
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

      return new controllers\CheckPermssionsReturn(true);
    }

    return new controllers\CheckPermssionsReturn(
      false,
      'No user was found with the given nickname and password',
    );
  }
}
