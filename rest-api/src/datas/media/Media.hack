namespace songpushTest\datas\media;

use namespace songpushTest\datas\user;

final class Media {
  public function __construct(
    private int $id,
    private user\User $owner,
    private bool $private,
    private bool $ageRestricted,
    private string $title,
    private Type $type,
    private string $src,
  )[] {
  }

  public function getId()[]: int {
    return $this->id;
  }

  public function getOwner()[]: user\User {
    return $this->owner;
  }

  public function isPrivate()[]: bool {
    return $this->private;
  }

  public function isAgeRestricted()[]: bool {
    return $this->ageRestricted;
  }

  public function getTitle()[]: string {
    return $this->title;
  }

  public function getType()[]: Type {
    return $this->type;
  }

  public function getSrc()[]: string {
    return $this->src;
  }
}
