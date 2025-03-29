namespace songpushTest\controllers\user;

use namespace songpushTest\{controllers, models};

final class UserById extends controllers\Controller {
    const type TResponseModel = models\User;

    <<__LateInit>> private models\User $foundUserResponse;

    <<__Override>>
    protected async function doAsync(): Awaitable<this::TResponseModel> {

        return $this->foundUserResponse;
        //  TRIALS
        //return new models\Me($userId, $user->getNickName(), $user->getName(), $isAgeRestricted);

        //return new models\UserById(0, "test", "test", false);
    }

    <<__Override>>
    protected async function checkPermssionsAsync(): Awaitable<bool> {
        $sessionId = $this->getSession()->getId();
        $userId = (int)$this->getParameters()['id'];

        $user = $this->getUserById($userId);

        if ($userId === $sessionId) {
            $this->foundUserResponse = new models\LoggedInUser(
                $userId,
                $user->getNickName(),
                $user->getName(),
                $this->isUserAgeRestricted($user),
            );

            return true;
        } else {
            $this->foundUserResponse =
                new models\BasicUser($userId, $user->getName());

            return true;
        }

        return false;
    }
}
