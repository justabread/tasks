namespace songpushTest\controllers;

use namespace songpushTest;
use type Facebook\Experimental\Http\Message\{
  ResponseInterface,
  ServerRequestInterface,
};
use function json_encode;

<<__ConsistentConstruct>>
abstract class Controller {
  abstract const type TResponseModel as songpushTest\models\ResponseModel;

  public function __construct(
    private ImmMap<string, string> $parameters,
    private ServerRequestInterface $request,
    private songpushTest\Session $session,
  )[] {}

  protected final function getParameters()[]: ImmMap<string, string> {
    return $this->parameters;
  }

  protected final function getRequest()[]: ServerRequestInterface {
    return $this->request;
  }

  protected final function getSession()[]: songpushTest\Session {
    return $this->session;
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
}
