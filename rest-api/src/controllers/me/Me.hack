namespace songpushTest\controllers\me;

use namespace songpushTest\{controllers, datas, exceptions, models};
use namespace Facebook\HackRouter;

final class Me extends controllers\Controller {
    const type TResponseModel = models\Me;

    <<__LateInit>> private datas\user\User $user;

    <<__Override>>
    protected async function doAsync(): Awaitable<this::TResponseModel> {
        $loggedInUser = $this->getLoggedInUserData();
        if ($loggedInUser !== null) {
            return new models\Me(
                $loggedInUser->getId(),
                $loggedInUser->getNickName(),
                $loggedInUser->getName(),
                $this->isUserAgeRestricted($loggedInUser),
            );
        }

        throw new HackRouter\NotFoundException('No user is logged in.');

        //  TRIALS
        // \var_dump($this->getSession());
        // $rawRequest = await $this->getRequest()->getBody()->readAllAsync();
        //$header = $request->getHeader('Authorization');
        // $requestBody = \json_decode($rawRequest, true);

        //return new models\Me(0, "test", "test", false);
    }

    <<__Override>>
    protected async function checkPermssionsAsync(
    ): Awaitable<controllers\CheckPermssionsReturn> {
        if (!$this->isValidLoginPresent()) {
            throw new exceptions\UnauthorizedException();
        }

        return new controllers\CheckPermssionsReturn(true);
    }
}
