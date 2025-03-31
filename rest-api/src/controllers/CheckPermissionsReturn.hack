namespace songpushTest\controllers;

final class CheckPermssionsReturn {
    public function __construct(
        public bool $success,
        public string $reason = '',
    )[] {

    }
}