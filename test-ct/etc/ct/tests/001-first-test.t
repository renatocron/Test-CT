
ok(1, '1 looks ok');
is(1, 1, '1 is 1');
isnt(1, 0, '1 isnt 0');

like('aa', qr/^a+$/, 'start and finish with a');
unlike('bb', qr/^a+$/, 'dont start and finish with a');


cmp_ok('1', '==', '1.0', '1 == 1.0');

is_deeply({ a => 1}, { a => 2-1}, 'is_deeply ok');

$tester->stash->{testes}++;


__DATA__


FOO '''

"""  ZOOO