# etc/ct/tests/user/01-roles.create.t

`ok(1)` resulted in success

# etc/ct/tests/002-user.create.t

> creating user id..

**user id is really 1** `is(1, 1)` resulted in success

# etc/ct/tests/001-first-test.t

`ok(1)` resulted in success

**1 is 1** `is(1, 1)` resulted in success

**1 isnt 0** `isnt(1, 0)` resulted in success

**start and finish with a** `like(q{aa}, (?^:^a+$))` resulted in success

**dont start and finish with a** `unlike(q{bb}, (?^:^a+$))` resulted in success

**1 == 1.0** `cmp_ok(1 == 1.0) ? 1 : 0` resulted in success

**is_deeply ok**

    $want = {
              'a' => 1
            };
    $expected = {
                  'a' => 1
                };
`is_deeply( $want, $expected )` resulted in success

