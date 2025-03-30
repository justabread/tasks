namespace songpushTest\models;

use namespace HH\Lib\Dict;
use type JsonSerializable;

abstract class ResponseModel implements JsonSerializable {
  public bool $success;
  private dict<string, mixed> $values = dict[];

  public function __construct(bool $success = true)[] {
    $this->success = $success;
  }

  public function formatValues(): void {
    $reflector = new \ReflectionClass(static::class);
    $constructor = $reflector->getConstructor();

    if ($constructor !== null) {
      foreach ($constructor->getParameters() as $param) {
        $paramName = $param->getName();
        $paramValue = $this->{$param->getName()} ?? null;

        $this->values =
          Dict\merge($this->values, dict[$paramName => $paramValue]);
      }
    }
  }

  final public function jsonSerialize(): dict<string, mixed> {
    $this->formatValues();

    $base = dict['success' => $this->success];

    return Dict\merge($base, dict['values' => $this->values]);
  }
}
