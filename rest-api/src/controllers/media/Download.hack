namespace songpushTest\controllers\media;

use namespace songpushTest\{controllers, datas, models};
use namespace Facebook\HackRouter;
use namespace HH\Asio;

final class Download extends controllers\Controller {
    const type TResponseModel = models\Download;

    <<__LateInit>> private datas\media\Media $media;

    <<__Override>>
    protected async function doAsync(): Awaitable<this::TResponseModel> {
        $mediaId = (int)$this->getParameters()['id'];

        $foundMedia = $this->getMediaById($mediaId);

        $response = await Asio\curl_exec($foundMedia->getSrc());

        if ($response !== '') {
            //base64 encode-olom a képet mert enélkül elhal a json_encode a Controllers.hack-ben
            $encoded = \base64_encode($response);
            return new models\Download($encoded);
        }

        throw new HackRouter\NotFoundException('Media src is not valid.');
    }

    <<__Override>>
    protected async function checkPermssionsAsync(): Awaitable<bool> {

        return true;
    }
}
