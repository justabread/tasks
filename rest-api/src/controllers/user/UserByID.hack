namespace songpushTest\controllers\user;

use namespace HH\Lib\{C, Vec};
use namespace songpushTest\{controllers, datas, models};
use type songpushTest\Session;

final class UserById extends controllers\Controller {
    const type TResponseModel = models\ResponseModel;

    <<__LateInit>> private datas\user\User $user;

    <<__Override>>
    protected async function doAsync(): Awaitable<this::TResponseModel> {
        $userId = (int)$this->getParameters()['id'];
        if($userId <= 1) {
            return new models\UserById($userId, "test");
        }else {
            return new models\UserByIdLogged($userId, "test", "testName", false);
        }
        //return new models\Me($userId, $user->getNickName(), $user->getName(), $isAgeRestricted);

        //return new models\UserById(0, "test", "test", false);
    }

    <<__Override>>
    protected async function checkPermssionsAsync(): Awaitable<bool> {
        return true;
    }
}