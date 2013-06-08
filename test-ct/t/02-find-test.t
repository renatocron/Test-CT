use warnings;
use strict;

use Test::More qw//;

Test::More::use_ok 'Test::CT';
my $tester = Test::CT->instance;

my $run = 0;
my $ref = sub {
    $run++;
};

my $testfile = Test::CT::TestFile->new(
    coderef => $ref,
    name => 'foo'
);

$tester->add_test($testfile);

Test::More::is( $run, 0, '$run = 0');
$tester->run( name => 'foo' ) for 1..3;
Test::More::is( $run, 1, '$run = 1');

$tester->run( name => 'foo', force_exec => 1);
Test::More::is( $run, 2, '$run = 2');

Test::More::done_testing;
