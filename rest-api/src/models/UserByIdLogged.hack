namespace songpushTest\models;

final class UserByIdLogged extends ResponseModel {
  public function __construct(public int $id, public string $nickname, public string $name, public bool $imAgeRestricted)[] {
    parent::__construct();
  }
}
