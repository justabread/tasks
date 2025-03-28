namespace songpushTest\datas\user;

enum class Users: User {
  User luna = new User(
    1,
    'luna',
    'a49cfe2629d1fed79f056c29f1f7a797e52a33cf', // rail34
    'Max Müller',
    22,
  );
  User europa = new User(
    2,
    'europa',
    '4877faa16342453614469c5bf898d30c8727cc18', // rubik27
    'Lena Schmidt',
    18,
  );
  User titan = new User(
    3,
    'titan',
    '92429d82a41e930486c6de5ebda9602d55c39986', // asdfasdf
    'Ben Fisher',
    20,
  );
  User IO = new User(
    4,
    'IO',
    'b1f9acec0de57c3964a96007d32059b7d16e13de', // mksdf
    'Anna Fisher',
    16,
  );
  User ganymede = new User(
    5,
    'ganymede',
    '00d05ff5bdfe9d9281fca07d6263f6c5cf8e649f', // meyer24
    'Sebastian Meyer',
    24,
  );
}
