namespace songpushTest\models;

abstract class ResponseModel {
  public function __construct(public bool $success = true)[] {
  }
}
