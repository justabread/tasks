namespace songpushTest\models;

final class Medias extends ResponseModel {
    public function __construct(
        public vec<Media> $results,
        public bool $hasMore,
    )[] {
        parent::__construct();
    }
}
