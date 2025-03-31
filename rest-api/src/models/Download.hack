namespace songpushTest\models;

final class Download extends ResponseModel {
    public function __construct(public string $src)[] {
        parent::__construct();
    }
}
