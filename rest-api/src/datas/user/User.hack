namespace songpushTest\datas\user;

use namespace HH\Lib\Str;

final class User {
  public function __construct(
    private int $id,
    private string $nickName,
    private string $passwordHash,
    private string $name,
    private int $age,
  )[] {}

  public function getId()[]: int {
    return $this->id;
  }

  public function getNickName()[]: string {
    return $this->nickName;
  }

  public function isMinePassword(string $hash)[]: bool {
    return Str\compare($this->passwordHash, $hash) === 0;
  }

  public function getName()[]: string {
    return $this->name;
  }

  public function getAge()[]: int {
    return $this->age;
  }
}
