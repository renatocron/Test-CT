use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Test::CT::Assembly;

my $compiler = Test::CT::Assembly->new(
    ct_dir => ( -e 'ct/' ? 'ct/' : ( -e '../ct/' ? '../ct/' : (-e $ARGV[0] ? $ARGV[0] : die("cant found ct_dir")) ))
);

$compiler->write_tests;
