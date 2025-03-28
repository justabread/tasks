namespace songpushTest\models;

abstract class User extends ResponseModel {
  public function __construct(public int $id, public string $name)[] {
    parent::__construct();
  }
}

final class BasicUser extends User {}

final class LoggedInUser extends User {
  public function __construct(public int $id, public string $nickname, public string $name, public bool $imAgeRestricted)[] {
    parent::__construct($id, $name);
  }
}
