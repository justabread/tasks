namespace songpushTest;

use namespace Facebook\HackRouter;
use namespace HH\Lib\{IO, Str};
use namespace Usox\HackTTP;
use type Exception;
use type Facebook\Experimental\Http\Message\ServerRequestInterface;
use function header;

final class Server {
  const int PIPE_READ_BITES = 1000;

  public static async function respondToAsync(
    ServerRequestInterface $request,
  ): Awaitable<void> {
    list($reader, $writer) = IO\pipe();

    $writeOutAwaitable = self::writeOutputAsync(IO\request_output(), $reader);

    $response = new HackTTP\Response($writer);

    $queryParameters = new ImmMap($request->getQueryParams());

    try {
      list($controllerClass, $parameters) =
        (new Router())->routeRequest($request);

      $controller = new $controllerClass(
        $parameters,
        $queryParameters,
        $request,
        await Session::loadAsync(
          $request->getServerParams()['HTTP_TOKEN'] ?? '',
        ),
      );

      $response = await $controller->runAsync($response);
    } catch (HackRouter\NotFoundException $_) {
      $response = $response->withStatus(404);
    } catch (HackRouter\MethodNotAllowedException $_) {
      $response = $response->withStatus(405);
    } catch (Exception $_) {
      $response = $response->withStatus(500);
    } finally {
      $writer->close();
    }

    header(Str\format(
      'HTTP/%s %d %s',
      $response->getProtocolVersion(),
      $response->getStatusCode(),
      $response->getReasonPhrase(),
    ));
    foreach ($response->getHeaders() as $key => $values) {
      header(Str\format('%s: %s', $key, Str\join($values, ', ')));
    }

    await $writeOutAwaitable;
  }

  private static async function writeOutputAsync(
    IO\WriteHandle $out,
    IO\CloseableReadHandle $input,
  ): Awaitable<void> {
    $content =
      await $input->readAllowPartialSuccessAsync(self::PIPE_READ_BITES);
    while (!Str\is_empty($content)) {
      // HHAST_IGNORE_ERROR[DontAwaitInALoop]
      await $out->writeAllAsync($content);
      // HHAST_IGNORE_ERROR[DontAwaitInALoop]
      $content =
        await $input->readAllowPartialSuccessAsync(self::PIPE_READ_BITES);
    }

    $input->close();
  }
}
