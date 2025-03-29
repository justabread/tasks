namespace songpushTest\controllers\user;

use namespace songpushTest\{controllers, models};
use type songpushTest\datas\user\{User};

final class UserById extends controllers\Controller {
    const type TResponseModel = models\User;

    <<__LateInit>> private User $user;

    <<__Override>>
    protected async function doAsync(): Awaitable<this::TResponseModel> {
        $sessionId = $this->getSession()->getId();
        $userId = (int)$this->getParameters()['id'];

        $user = $this->getUserById($userId);

        if ($userId === $sessionId) {
            return new models\LoggedInUser(
                $userId,
                $user->getNickName(),
                $user->getName(),
                $this->isAgeRestricted($user),
            );
        }

        return new models\BasicUser($userId, $user->getName());

        //  TRIALS
        //return new models\Me($userId, $user->getNickName(), $user->getName(), $isAgeRestricted);

        //return new models\UserById(0, "test", "test", false);
    }

    <<__Override>>
    protected async function checkPermssionsAsync(): Awaitable<bool> {
        return $this->isValidLoginPresent();
    }
}
