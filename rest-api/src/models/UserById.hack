namespace songpushTest\models;

final class UserById extends ResponseModel {
  public function __construct(public int $id, public string $name)[] {
    parent::__construct();
  }
}
