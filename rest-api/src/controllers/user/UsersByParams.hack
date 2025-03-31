namespace songpushTest\controllers\user;

use namespace songpushTest\{controllers, datas, models};
use namespace HH\Lib\{C, Str};
use namespace HH;
use namespace Facebook\HackRouter;

final class UsersByParams extends controllers\Controller {
    const type TResponseModel = models\Users;

    <<__LateInit>> private models\Users $foundUsersResponse;

    <<__Override>>
    protected async function doAsync(): Awaitable<this::TResponseModel> {

        return $this->foundUsersResponse;
        // if (
        //     \array_key_exists('name', $queryParams) &&
        //     \array_key_exists('ids', $queryParams)
        // ) {
        //     $users = $this->getUsersByIds($userIds);
        // }

        // return new models\Users(
        //     vec[
        //         new models\BasicUser(-1, $this->getQueryParameters()['name']),
        //         new models\LoggedInUser(
        //             19,
        //             'TestLoggedUserNickName',
        //             'TestLoggedUserName',
        //             false,
        //         ),
        //     ],
        //     false,
        // );
    }

    <<__Override>>
    protected async function checkPermssionsAsync(
    ): Awaitable<controllers\CheckPermssionsReturn> {
        $sessionId = $this->getSession()->getId();
        // \error_log(
        //     \json_encode($this->getQueryParameters(), \JSON_PRETTY_PRINT),
        // );
        // $userName = $this->getQueryParameters()['name'];
        // $userIds = $this->getQueryParameters()['ids'];
        // $skip = (int)$this->getQueryParameters()['skip'];
        // $limit = (int)$this->getQueryParameters()['limit'];

        $queryParams = $this->getQueryParameters();

        $skip = 0;
        $limit = 3;

        $users = vec[];

        //Ha a skip query parameter létezik és valid integer akkor kiveszem az értékét
        if (
            \array_key_exists('skip', $queryParams) &&
            Str\to_int($queryParams['skip']) !== null
        ) {
            $skip = (int)$queryParams['skip'];
        }

        //Ha a limit query parameter létezik és valid integer akkor kiveszem az értékét
        if (
            \array_key_exists('limit', $queryParams) &&
            Str\to_int($queryParams['limit']) !== null
        ) {
            $limit = (int)$queryParams['limit'];
        }

        //Kiveszem a nevet és a userids-t query params-ból. Ha nincs megadva a név akkor üres string lesz,
        //Ha nincs megadva vagy nem helyesen van megadva az id akkor üres vektor
        $name = \array_key_exists('name', $queryParams)
            ? $queryParams['name'] as string
            : '';

        $userIds = $this->sanitizeArrayFromParam($queryParams, 'ids');

        $users = $this->getUsersByParams($name, $userIds, $skip, $limit);
        $foundUsersResponseCount = C\count($users);

        //Ha nem találtunk egy user-t sem akkor exception time
        if ($foundUsersResponseCount === 0) {
            throw new HackRouter\NotFoundException('No users found');
        }

        $usersResponse = vec[];

        //Készítek response object-eket a talált userekből
        foreach ($users as $user) {
            if ($user->getId() === $sessionId) {
                $usersResponse[] = new models\LoggedInUser(
                    $user->getId(),
                    $user->getNickName(),
                    $user->getName(),
                    $this->isUserAgeRestricted($user),
                );
            } else {
                $usersResponse[] =
                    new models\BasicUser($user->getId(), $user->getName());
            }
        }

        //Átállítom a foundUsersResponse-t a talált userekre és ha a talált userek száma kevesebb
        //az összes userénél akkor igazra álítom a hasMore-t
        $this->foundUsersResponse = new models\Users(
            $usersResponse,
            $foundUsersResponseCount < C\count(datas\user\Users::getValues()),
        );

        return new controllers\CheckPermssionsReturn(true);
    }
}

//UNUSED
// if (!C\is_empty($userIds)) {
//     //Lekérem az összes user-t amiknek az id-ja a kapott id-kkal megegyezik
//     $users = $this->getUsersByIds($userIds, $skip, $limit);
//     $foundUsersResponseCount = C\count($users);

//     //Ha nem találtunk egy user-t sem akkor exception time
//     if ($foundUsersResponseCount === 0) {
//         throw new HackRouter\NotFoundException('No users found');
//     }

//     $usersResponse = vec[];

//     //Készítek response object-eket a talált userekből
//     foreach ($users as $user) {
//         if ($user->getId() === $sessionId) {
//             $usersResponse[] = new models\LoggedInUser(
//                 $user->getId(),
//                 $user->getNickName(),
//                 $user->getName(),
//                 $this->isUserAgeRestricted($user),
//             );
//         } else {
//             $usersResponse[] =
//                 new models\BasicUser($user->getId(), $user->getName());
//         }
//     }

//     //Visszatérek a talált userekkel és ha a talált userek száma kevesebb az összes userénél akkor igazra álítom a hasMore-t
//     $this->foundUsersResponse = new models\Users(
//         $usersResponse,
//         $foundUsersResponseCount <
//             C\count(datas\user\Users::getValues()),
//     );

//     return true;
// }else if

//Ha a keresett user id-k query paraméter létezik
// if (\array_key_exists('ids', $queryParams)) {
//     //Kijavítom a helytelen '-ket helyes "-re, megkönnyítve a front-end dolgát
//     $jsonString = Str\replace($queryParams['ids'] as string, "'", '"');

//     //Ellenőrzöm hogy az Id-d helyes JSON formátumban érkeztek-e a request-ből
//     if (
//         !Str\starts_with($jsonString, '[') ||
//         !Str\ends_with($jsonString, ']')
//     ) {
//         throw new \InvalidArgumentException('Invalid JSON array');
//     }
//     //Dekódolom az Id-ket és dobok egy exception ha helytelen a json string
//     $decoded = \json_decode($jsonString, true);
//     if ($decoded === null) {
//         throw new \InvalidArgumentException('Malformed JSON');
//     }

//     //Dict-ből vectorrá konvertálom az id-ket és kiveszem belőlük a helytelen formátumúakat
//     $userIds = Vec\map_with_key($decoded, ($_key, $value) ==> $value);

//     $userIds = Vec\map(
//         $userIds,
//         $id ==> {
//             if (\is_int($id)) {
//                 return $id;
//             }

//             if (\is_string($id) && Str\to_int($id) !== null) {
//                 return Str\to_int($id);
//             }

//             return null;
//         },
//     )
//         |> Vec\filter_nulls($$);

//     //Lekérem az összes user-t amiknek az id-ja a kapott id-kkal megegyezik
//     $users = $this->getUsersByIds($userIds, $skip, $limit);
//     $foundUsersResponseCount = C\count($users);

//     //Ha nem találtunk egy user-t sem akkor exception time
//     if ($foundUsersResponseCount === 0) {
//         throw new HackRouter\NotFoundException('No users found');
//     }

//     $usersResponse = vec[];

//     //Készítek response object-eket a talált userekből
//     foreach ($users as $user) {
//         if ($user->getId() === $sessionId) {
//             $usersResponse[] = new models\LoggedInUser(
//                 $user->getId(),
//                 $user->getNickName(),
//                 $user->getName(),
//                 $this->isUserAgeRestricted($user),
//             );
//         } else {
//             $usersResponse[] =
//                 new models\BasicUser($user->getId(), $user->getName());
//         }
//     }

//     //Visszatérek a talált userekkel és ha a talált userek száma kevesebb az összes userénél akkor igazra álítom a hasMore-t
//     $this->foundUsersResponse = new models\Users(
//         $usersResponse,
//         $foundUsersResponseCount <
//             C\count(datas\user\Users::getValues()),
//     );

//     return true;
// } else if (\array_key_exists('name', $queryParams)) {
//     $name = $queryParams['name'] as string;

//     $users = $this->getUsersByName($name);
//     $foundUsersResponseCount = C\count($users);

//     //Ha nem találtunk egy user-t sem akkor exception time
//     if ($foundUsersResponseCount === 0) {
//         throw new HackRouter\NotFoundException('No users found');
//     }

//     $usersResponse = vec[];

//     //Készítek response object-eket a talált userekből
//     foreach ($users as $user) {
//         if ($user->getId() === $sessionId) {
//             $usersResponse[] = new models\LoggedInUser(
//                 $user->getId(),
//                 $user->getNickName(),
//                 $user->getName(),
//                 $this->isUserAgeRestricted($user),
//             );
//         } else {
//             $usersResponse[] =
//                 new models\BasicUser($user->getId(), $user->getName());
//         }
//     }

//     //Visszatérek a talált userekkel és ha a talált userek száma kevesebb az összes userénél akkor igazra álítom a hasMore-t
//     $this->foundUsersResponse = new models\Users(
//         $usersResponse,
//         $foundUsersResponseCount <
//             C\count(datas\user\Users::getValues()),
//     );

//     return true;

// }
