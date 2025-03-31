namespace songpushTest\controllers;

use namespace HH\Lib\{C, Str, Vec};
use namespace songpushTest\{datas};
use namespace songpushTest;
use type songpushTest\datas\user\{User};
use type songpushTest\datas\media\{Media};
use type Facebook\Experimental\Http\Message\{
  ResponseInterface,
  ServerRequestInterface,
};
use namespace Facebook\HackRouter;
use function json_encode;

<<__ConsistentConstruct>>
abstract class Controller {
  abstract const type TResponseModel as songpushTest\models\ResponseModel;

  public function __construct(
    private ImmMap<string, string> $parameters,
    private ImmMap<string, string> $queryParameters,
    private ServerRequestInterface $request,
    private songpushTest\Session $session,
  )[] {}

  protected final function getParameters()[]: ImmMap<string, string> {
    return $this->parameters;
  }

  protected final function getQueryParameters()[]: ImmMap<string, string> {
    return $this->queryParameters;
  }

  protected final function getRequest()[]: ServerRequestInterface {
    return $this->request;
  }

  protected final function getSession()[]: songpushTest\Session {
    return $this->session;
  }

  protected final function isUserAgeRestricted(User $user)[]: bool {
    return $user?->getAge() < 18 && !$this->session->getCanViewAgeRestricted();
  }

  public async function runAsync(
    ResponseInterface $response,
  ): Awaitable<ResponseInterface> {
    if ((await $this->checkPermssionsAsync())) {
      $responseModel = await $this->doAsync();
    } else {
      $responseModel = new songpushTest\models\VoidResponse(false);
    }

    await $response->getBody()->writeAllAsync(json_encode($responseModel));

    return $response;
  }

  abstract protected function doAsync(): Awaitable<this::TResponseModel>;
  abstract protected function checkPermssionsAsync(): Awaitable<bool>;

  protected function getUserById(int $userId): User {
    $user = Vec\filter(
      datas\user\Users::getValues(),
      $user ==> $user->getId() === $userId,
    )
      |> C\first($$);

    if ($user === null) {
      throw new HackRouter\NotFoundException('User not found');
    }

    return $user;
  }

  protected function findUserById(int $userId): ?User {
    $user = Vec\filter(
      datas\user\Users::getValues(),
      $user ==> $user->getId() === $userId,
    )
      |> C\first($$);

    return $user;
  }

  // protected function getUserByName(string $name): User {
  //   $user = Vec\filter(
  //     datas\user\Users::getValues(),
  //     $user ==> $user->getName() === $name,
  //   )
  //     |> C\first($$);

  //   if ($user === null) {
  //     throw new HackRouter\NotFoundException('User not found');
  //   }

  //   return $user;
  // }

  // protected function findUserByName(string $name): ?User {
  //   $user = Vec\filter(
  //     datas\user\Users::getValues(),
  //     $user ==> $user->getName() === $name,
  //   )
  //     |> C\first($$);

  //   return $user;
  // }

  protected function getUsersByIds(
    vec<int> $userIds,
    int $skip = 0,
    int $limit = 3,
  ): vec<User> {

    $foundUsers = vec[];

    $foundUserCount = 0;

    //Végig megyek az összes keresett userId-n
    for ($i = 0; $i < C\count($userIds); $i++) {
      //Ha már találtunk annyit mint a megadott limit akkor kiugrom a ciklusból
      if ($foundUserCount === $limit) {
        break;
      }

      //Megnézem hogy benne létezik e az éppeni userId
      $currentUser = $this->findUserById($userIds[$i]);

      //Ha igen, akkor hozzáfűzöm a talált userekhez
      if ($currentUser !== null) {
        $foundUsers[] = $currentUser;

        //Inkrementálom a talált userek számát
        $foundUserCount++;
      }
    }

    //Kitörlöm az első $skip számú elemet
    $foundUsers = Vec\drop($foundUsers, $skip);

    return $foundUsers;
  }

  protected function getUsersByParams(
    string $userName = '',
    vec<int> $userIds = vec[],
    int $skip = 0,
    int $limit = 3,
  ): vec<User> {

    // $foundUsers = Vec\filter(
    //   datas\user\Users::getValues(),
    //   $user ==> $user->getName() === $userName,
    // );

    $foundUsers = Vec\filter(
      datas\user\Users::getValues(),
      $user ==> {

        //A $nameMatches default értéke igaz, hogy visszatérjen az összes userrel ha nincs megadva se a név se a userIds
        $nameMatches = true;

        //Ha a userName nem üres string, tehát meg van adva akkor a nameMatches akkor lesz igaz,
        //ha az éppen vizsgált user neve megegyezik a megadott névvel
        if ($userName !== '') {
          $nameMatches = $user->getName() === $userName;
        }

        //Ha a userids nem üres akkor azokat adja vissza ahol a userids és a név létezik a userben
        //Ez akkor is működik ha nincs megadva username mert a nameMatches alapvetően igazra van állítva
        if (!C\is_empty($userIds)) {
          return $nameMatches && C\contains($userIds, $user->getId());
        }

        return $nameMatches;
      },
    );

    //Először kiveszem az első $skip számú elemet és aztán kitörlöm az utolsó $limit-nyit
    $foundUsers = Vec\drop($foundUsers, $skip);
    $foundUsers = Vec\take($foundUsers, $limit);

    return $foundUsers;

    // for($i = $skip; $i <)

    //   if ($foundUserCount === $limit) {
    //     break;
    //   }

    //   $currentUser = $this->findUserById($userIds[$i]);

    //   if ($currentUser !== null) {
    //     $users[] = $currentUser;
    //     $foundUserCount++;
    //   }
    // return $foundUsers;

  }

  protected function getMediaById(int $mediaId): Media {
    $media = Vec\filter(
      datas\media\Medias::getValues(),
      $media ==> $media->getId() === $mediaId,
    )
      |> C\first($$);

    if ($media === null) {
      throw new HackRouter\NotFoundException('Media not found');
    }

    return $media;
  }

  protected function getMediasByParams(
    string $mediaTitle = '',
    vec<int> $mediaIds = vec[],
    int $ownerId = 0,
    ?bool $isAgeRestricted = null,
    ?bool $isPrivate = null,
    int $skip = 0,
    int $limit = 3,
  ): vec<Media> {
    $foundMedias = Vec\filter(
      datas\media\Medias::getValues(),
      $media ==> {
        $titleMatches =
          ($mediaTitle === '') || ($media->getTitle() === $mediaTitle);

        $idMatches =
          C\is_empty($mediaIds) || C\contains($mediaIds, $media->getId());

        $ownerMatches =
          ($ownerId === 0) || ($media->getOwner()->getId() === $ownerId);

        $ageRestrictionMatches = ($isAgeRestricted === null) ||
          ($media->isAgeRestricted() === $isAgeRestricted);

        $privacyMatches =
          ($isPrivate === null) || ($media->isPrivate() === $isPrivate);

        return $titleMatches &&
          $idMatches &&
          $ownerMatches &&
          $ageRestrictionMatches &&
          $privacyMatches;
      },
    );

    //Először kiveszem az első $skip számú elemet és aztán kitörlöm az utolsó $limit-nyit
    $foundMedias = Vec\drop($foundMedias, $skip);
    $foundMedias = Vec\take($foundMedias, $limit);

    return $foundMedias;
  }

  protected function getLoggedInUserData(): ?User {
    $userId = 0;
    $user = null;

    if ($this->getSession()->isLogged()) {
      $userId = $this->getSession()->getId();
      $user = $this->getUserById($userId);
    }

    return $user;
  }

  //Technikailag egy egyszerűbb (gyorsabb) módja megnézni hogy bejelentkezett sessionről van-e szó
  protected function isValidLoginPresent(): bool {
    $isLogged = $this->getSession()->isLogged();
    $userId = $this->getSession()->getId();

    return $userId > 0 && $isLogged;
  }

  //Kivesz minden helytelen formátumú id-t és készít egy vektort a megadott id-kből
  protected function sanitizeArrayFromParam(
    ImmMap<string, string> $queryParams,
    string $key,
  ): vec<int> {
    if (\array_key_exists($key, $queryParams)) {
      //Kijavítom a helytelen '-ket helyes "-re, megkönnyítve a front-end dolgát
      $jsonString = Str\replace($queryParams[$key] as string, "'", '"');

      //Ellenőrzöm hogy az Id-d helyes JSON formátumban érkeztek-e a request-ből
      if (
        !Str\starts_with($jsonString, '[') || !Str\ends_with($jsonString, ']')
      ) {
        throw new \InvalidArgumentException('Invalid JSON array');
      }
      //Dekódolom az Id-ket és dobok egy exception ha helytelen a json string
      $decoded = \json_decode($jsonString, true);
      if ($decoded === null) {
        throw new \InvalidArgumentException('Malformed JSON');
      }

      //Dict-ből vectorrá konvertálom az id-ket és kiveszem belőlük a helytelen formátumúakat
      $userIds = Vec\map_with_key($decoded, ($_key, $value) ==> $value);

      $userIds = Vec\map(
        $userIds,
        $id ==> {
          if (\is_int($id)) {
            return $id;
          }

          if (\is_string($id) && Str\to_int($id) !== null) {
            return Str\to_int($id);
          }

          return null;
        },
      )
        |> Vec\filter_nulls($$);

      return $userIds;
    }

    return vec[];
  }
}
