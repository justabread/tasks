namespace songpushTest\controllers\me;

use namespace HH\Lib\{C, Vec};
use namespace songpushTest\{controllers, datas, models};
use type songpushTest\Session;

final class Me extends controllers\Controller {
    const type TResponseModel = models\Me;

    <<__LateInit>> private datas\user\User $user;

    <<__Override>>
    protected async function doAsync(): Awaitable<this::TResponseModel> {
        // \var_dump($this->getSession());
        $userId = $this->getSession()->getId();
        // $rawRequest = await $this->getRequest()->getBody()->readAllAsync();
        //$header = $request->getHeader('Authorization');
        // $requestBody = \json_decode($rawRequest, true);

        $user = Vec\filter(
            datas\user\Users::getValues(),
            $user ==>
                $user->getId() === $userId,
        )
            |> C\first($$) as nonnull;;

        

        $isAgeRestricted = $user?->getAge() < 18 ?? true;


        return new models\Me($userId, $user->getNickName(), $user->getName(), $isAgeRestricted);

        //return new models\Me(0, "test", "test", false);
    }

    <<__Override>>
    protected async function checkPermssionsAsync(): Awaitable<bool> {
        $isLogged = $this->getSession()->isLogged();
        $userId = $this->getSession()->getId();

        return $userId > 0 && $isLogged;
    }
}