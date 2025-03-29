namespace songpushTest\models;

final class Users extends ResponseModel {
    public function __construct(
        public vec<User> $results,
        public bool $hasMore,
    )[] {
        parent::__construct();
    }
}
