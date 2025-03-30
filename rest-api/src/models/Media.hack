namespace songpushTest\models;

use namespace songpushTest\datas\{media};

abstract class Media extends ResponseModel {
    public function __construct(
        public int $id,
        public int $owner,
        public bool $ageRestricted,
        public string $title,
        public media\Type $type,
    )[] {
        parent::__construct();
    }
}

final class BasicMedia extends Media {}

final class OwnedMedia extends Media {
    public function __construct(
        public int $id,
        public int $owner,
        public bool $private,
        public bool $ageRestricted,
        public string $title,
        public media\Type $type,
    )[] {
        parent::__construct($id, $owner, $ageRestricted, $title, $type);
    }
}
