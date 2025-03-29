namespace songpushTest\controllers\login;

// use namespace HH\Lib\{C, Vec};
use namespace songpushTest\{controllers, models};
// use type songpushTest\Session;
// use function json_decode;
// use function sha1;
use namespace Facebook\HackRouter;

final class MediaById extends controllers\Controller {
    const type TResponseModel = models\Media;

    <<__LateInit>> private models\Media $foundMediaResponse;

    <<__Override>>
    protected async function doAsync(): Awaitable<this::TResponseModel> {

        return $this->foundMediaResponse;
    }

    <<__Override>>
    protected async function checkPermssionsAsync(): Awaitable<bool> {
        $mediaId = (int)$this->getParameters()['id'];

        //Lekérem azt a médiát amelyiknek az id-je requestben érkezett
        $foundMedia = $this->getMediaById($mediaId);

        //Lekérem a bejelentkezett felhasználó adatait (null ha a session bejelentkezés nélküli)
        $loggedInUser = $this->getLoggedInUserData();

        //Olvashatóság kedvéért eltárolom egy változóba, hogyha a bejelentkezett felhasználó a lekért média tulajdonosa
        $isLoggedInUserMediaOwner = $loggedInUser !== null
            ? $foundMedia->getOwner()->getId() === $loggedInUser->getId()
            : false;

        if (
            (
                $foundMedia->isAgeRestricted() &&
                (
                    $loggedInUser === null ||
                    (
                        $loggedInUser !== null &&
                        $this->isUserAgeRestricted($loggedInUser)
                    )
                )
            ) ||
            (
                $foundMedia->isPrivate() &&
                (
                    $loggedInUser === null ||
                    ($loggedInUser !== null && !$isLoggedInUserMediaOwner)
                )
            )

        ) {
            throw new HackRouter\NotFoundException();
        }

        if ($loggedInUser !== null && $isLoggedInUserMediaOwner) {
            $this->foundMediaResponse = new models\OwnedMedia(
                $foundMedia->getId(),
                $foundMedia->getOwner()->getId(),
                $foundMedia->isPrivate(),
                $foundMedia->isAgeRestricted(),
                $foundMedia->getTitle(),
                $foundMedia->getType(),
            );
            return true;
        } else {
            $this->foundMediaResponse = new models\BasicMedia(
                $foundMedia->getId(),
                $foundMedia->getOwner()->getId(),
                $foundMedia->isAgeRestricted(),
                $foundMedia->getTitle(),
                $foundMedia->getType(),
            );
            return true;
        }

        return false;
    }
}
