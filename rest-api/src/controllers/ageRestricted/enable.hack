namespace songpushTest\controllers\ageRestricted;

use namespace HH\Lib\{C, Vec};
use namespace songpushTest\{controllers, datas, models};
use function sha1;
use type songpushTest\Session;

final class Enable extends controllers\Controller {
    const type TResponseModel = models\VoidResponse;

    <<__LateInit>> private datas\user\User $user;

    <<__Override>>
    protected async function doAsync(): Awaitable<this::TResponseModel> {
        if ($this->getSession()->getToken() !== null) {
            $sureToken = $this->getSession()->getToken() as string;
            await Session::updateAgeRestrictionAsync($sureToken, true);

            return new models\VoidResponse(true);
        }

        return
            new models\VoidResponse(false, 'No user is logged in currently.');
    }

    <<__Override>>
    protected async function checkPermssionsAsync(
    ): Awaitable<controllers\CheckPermssionsReturn> {
        $rawRequest = await $this->getRequest()->getBody()->readAllAsync();
        $requestBody = \json_decode($rawRequest, true);

        if ($requestBody === null) {
            return new controllers\CheckPermssionsReturn(
                false,
                'No request body was provided',
            );
        }

        $password = $requestBody['password'] ?? null;

        if ($password === null) {
            return new controllers\CheckPermssionsReturn(
                false,
                'No password was given in the request.',
            );
        }

        $hash = sha1($password);

        $user = Vec\filter(
            datas\user\Users::getValues(),
            $user ==> $user->isMinePassword($hash),
        )
            |> C\first($$);

        if ($user !== null && $this->getSession()->getId() === $user->getId()) {
            return new controllers\CheckPermssionsReturn(true);
        }

        return new controllers\CheckPermssionsReturn(
            false,
            'No user was found with the given password, or the given password is not the password of the user currently logged in.',
        );
    }
}
