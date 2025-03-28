namespace songpushTest\controllers\user;

use namespace HH\Lib\{C, Vec};
use namespace songpushTest\{controllers, datas, models};
use type songpushTest\datas\user\{User};
use namespace Facebook\HackRouter;

final class UserById extends controllers\Controller {
    const type TResponseModel = models\ResponseModel;

    <<__LateInit>> private User $user;

    protected function findUser(int $userId): ?User {
        $user = Vec\filter(
            datas\user\Users::getValues(),
            $user ==>
                $user->getId() === $userId,
        )
            |> C\first($$);

        if($user === null) {
            return null;
        }

        return $user;
    }

    <<__Override>>
    protected async function doAsync(): Awaitable<this::TResponseModel> {
        $sessionId = $this->getSession()->getId();
        $userId = (int)$this->getParameters()['id'];

        $user = $this->findUser($userId);

        if($user !== null) {
            if($userId === $sessionId ) {
                return new models\UserByIdLogged($userId, $user->getNickName(), $user->getName(), $this->isAgeRestricted($user));
            }

            return new models\UserById($userId, $user->getName());
        }

        throw new HackRouter\NotFoundException('User not found');
        //return new models\Me($userId, $user->getNickName(), $user->getName(), $isAgeRestricted);

        //return new models\UserById(0, "test", "test", false);
    }

    <<__Override>>
    protected async function checkPermssionsAsync(): Awaitable<bool> {
        return true;
    }
}
