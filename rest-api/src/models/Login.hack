namespace songpushTest\models;

final class Login extends ResponseModel {
  public function __construct(public string $token)[] {
    parent::__construct();
  }
}
