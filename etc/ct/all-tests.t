use Test::CT;
use FindBin qw($Bin);
use lib "$Bin/../lib";

my $tester = Test::CT->instance;
my $test_ct_config = {
                    'log_writter' => {
                                       'format' => 'Markdown',
                                       'path' => 'etc/test_out/doc/'
                                     }
                  };

$tester->config($test_ct_config);
# etc/ct/boot/01-load-heavy-things.ct.t
# use Catalyst::Test q(YourCatalystApp);
# you can write anything here!
# etc/ct/boot/02-do-another-thing-after-01.ct.t
# my $schema = MyApp->model('DB');
my $schema = { keep => 'simple' };
# etc/ct/tests/001-first-test.t 
do { my $ref = sub { 

ok(1, '1 looks ok');
is(1, 1, '1 is 1');
isnt(1, 0, '1 isnt 0');

like('aa', qr/^a+$/, 'start and finish with a');
unlike('bb', qr/^a+$/, 'dont start and finish with a');


cmp_ok('1', '==', '1.0', '1 == 1.0');

is_deeply({ a => 1}, { a => 2-1}, 'is_deeply ok');

$tester->stash->{testes}++;


};
$tester->add_test(Test::CT::TestFile->new( coderef => $ref, name => 'etc/ct/tests/001-first-test.t' ));
};

eval {
    
$tester->run( name => 'etc/ct/tests/001-first-test.t');

    die 'rollback';
};
die $@ unless $@ =~ /rollback/;


# etc/ct/tests/002-user.create.t 
do { my $ref = sub { 

# supposed you created a user somewhere and
# save the result on $user;

my $user = {
    id   => 1,
    name => 'foo',
};
diag("creating user id..");
is($user->{id}, 1, 'user id is really 1');

$tester->stash->{user} = $user;



};
$tester->add_test(Test::CT::TestFile->new( coderef => $ref, name => 'etc/ct/tests/002-user.create.t' ));
};

eval {
    
$tester->run( name => 'etc/ct/tests/002-user.create.t');

    die 'rollback';
};
die $@ unless $@ =~ /rollback/;


# etc/ct/tests/user/01-roles.create.t 
do { my $ref = sub { 
ok(1, '1 is ok!');


};
$tester->add_test(Test::CT::TestFile->new( coderef => $ref, name => 'etc/ct/tests/user/01-roles.create.t' ));
};

eval {
    
$tester->run( name => 'etc/ct/tests/user/01-roles.create.t');

    die 'rollback';
};
die $@ unless $@ =~ /rollback/;



$tester->finalize;
done_testing;
