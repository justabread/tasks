namespace songpushTest\controllers\me;

use namespace songpushTest\{controllers, datas, models};

final class Me extends controllers\Controller {
    const type TResponseModel = models\Me;

    <<__LateInit>> private datas\user\User $user;

    <<__Override>>
    protected async function doAsync(): Awaitable<this::TResponseModel> {

        $userId = $this->getSession()->getId();

        $user = $this->getUserById($userId);

        return new models\Me(
            $userId,
            $user->getNickName(),
            $user->getName(),
            $this->isAgeRestricted($user),
        );

        //  TRIALS
        // \var_dump($this->getSession());
        // $rawRequest = await $this->getRequest()->getBody()->readAllAsync();
        //$header = $request->getHeader('Authorization');
        // $requestBody = \json_decode($rawRequest, true);

        //return new models\Me(0, "test", "test", false);
    }

    <<__Override>>
    protected async function checkPermssionsAsync(): Awaitable<bool> {
        return $this->isValidLoginPresent();
    }
}
