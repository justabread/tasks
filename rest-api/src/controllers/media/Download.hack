namespace songpushTest\controllers\media;

use namespace songpushTest\{controllers, datas, models};
use namespace Facebook\HackRouter;
use namespace HH\Asio;

final class Download extends controllers\Controller {
    const type TResponseModel = models\Download;

    <<__LateInit>> private string $mediaData;

    <<__Override>>
    protected async function doAsync(): Awaitable<this::TResponseModel> {

        return new models\Download($this->mediaData);

    }

    <<__Override>>
    protected async function checkPermssionsAsync(
    ): Awaitable<controllers\CheckPermssionsReturn> {
        $mediaId = (int)$this->getParameters()['id'];

        $foundMedia = $this->getMediaById($mediaId);

        $response = await Asio\curl_exec($foundMedia->getSrc());

        if ($response === '') {
            throw new HackRouter\NotFoundException('Media src is not valid.');

        }
        //base64 encode-olom a képet mert enélkül elhal a json_encode a Controllers.hack-ben
        $this->mediaData = \base64_encode($response);

        return new controllers\CheckPermssionsReturn(true);
    }
}
