namespace songpushTest\controllers\media;

use namespace songpushTest\{controllers, datas, models};
use namespace HH\Lib\{C, Str};
use namespace HH;
use namespace Facebook\HackRouter;

final class MediasByParams extends controllers\Controller {
    const type TResponseModel = models\Medias;

    <<__LateInit>> private models\Medias $foundMediasResponse;

    //Üres string-gel tér vissza ha nem létezik a kulcs
    protected function sanitizeStringFromParam(
        ImmMap<string, string> $queryParams,
        string $key,
    ): string {
        $string = \array_key_exists($key, $queryParams)
            ? $queryParams[$key] as string
            : '';

        return $string;
    }

    //0-val tér vissza hogyha a kulcs nem létezik vagy a kulcsot nem lehet valid int-é alakítani
    protected function sanitizeIntFromParam(
        ImmMap<string, string> $queryParams,
        string $key,
    ): int {
        $int = \array_key_exists($key, $queryParams)
            ? Str\to_int($queryParams[$key] as string) ?? 0
            : 0;

        return $int;
    }

    protected function sanitizeBoolFromParam(
        ImmMap<string, string> $queryParams,
        string $key,
    ): ?bool {
        $bool = \array_key_exists($key, $queryParams)
            ? (
                $queryParams[$key] as string === '1' ||
                Str\lowercase($queryParams[$key] as string) === 'true'
            )
            : null;

        return $bool;
    }

    <<__Override>>
    protected async function doAsync(): Awaitable<this::TResponseModel> {

        return $this->foundMediasResponse;

        // return new models\Medias(
        //     vec[new models\BasicMedia(
        //         1,
        //         1,
        //         false,
        //         'aaa',
        //         datas\media\Type::GIF,
        //     )],
        //     false,
        // );
    }

    <<__Override>>
    protected async function checkPermssionsAsync(
    ): Awaitable<controllers\CheckPermssionsReturn> {
        $sessionId = $this->getSession()->getId();
        $queryParams = $this->getQueryParameters();

        $skip = 0;
        $limit = 3;

        $foundMedias = vec[];

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

        //Lekérem a tisztított értékét a bemeneti paramétereknek
        $title = $this->sanitizeStringFromParam($queryParams, 'title');

        $mediaIds = $this->sanitizeArrayFromParam($queryParams, 'ids');

        $ownerId = $this->sanitizeIntFromParam($queryParams, 'owner');

        $isAgeRestricted =
            $this->sanitizeBoolFromParam($queryParams, 'ageRestricted');

        $isPrivate = $this->sanitizeBoolFromParam($queryParams, 'private');

        $foundMedias = $this->getMediasByParams(
            $title,
            $mediaIds,
            $ownerId,
            $isAgeRestricted,
            $isPrivate,
            $skip,
            $limit,
        );

        $foundMediasResponseCount = C\count($foundMedias);

        //Ha nem találtunk egy mediát-t sem akkor exception time
        if ($foundMediasResponseCount === 0) {
            throw new HackRouter\NotFoundException('No medias found');
        }

        $mediasResponse = vec[];

        //Készítek response object-eket a talált mediákból
        foreach ($foundMedias as $media) {
            if ($media->getOwner()->getId() === $sessionId) {
                $mediasResponse[] = new models\OwnedMedia(
                    $media->getId(),
                    $media->getOwner()->getId(),
                    $media->isPrivate(),
                    $media->isAgeRestricted(),
                    $media->getTitle(),
                    $media->getType(),
                );
            } else {
                $mediasResponse[] = new models\BasicMedia(
                    $media->getId(),
                    $media->getOwner()->getId(),
                    $media->isAgeRestricted(),
                    $media->getTitle(),
                    $media->getType(),
                );
            }
        }

        //Átállítom a foundMediasResponse-t a talált mediákra és ha a talált mediák száma kevesebb
        //az összes mediánál akkor igazra álítom a hasMore-t
        $this->foundMediasResponse = new models\Medias(
            $mediasResponse,
            $foundMediasResponseCount <
                C\count(datas\media\Medias::getValues()),
        );

        return new controllers\CheckPermssionsReturn(true);
    }
}
