# PODNAME: ctupdate

use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Test::CT::Assembly;
use Getopt::Long;

my $ct_dir;
my $t_dir;

GetOptions(
    "in=s"   => \$ct_dir,
    "out=s"  => \$t_dir,
) or exit;


$ct_dir ||= ( -e 'ct/' ? 'ct/' : ( -e '../ct/' ? '../ct/' : (-e $ARGV[0] ? $ARGV[0] : die("cant found ct_dir")) ));

my $compiler = Test::CT::Assembly->new(
    ct_dir          => $ct_dir,
    (defined $t_dir ? (test_dir_output => $t_dir) : ())
);

$compiler->write_tests;
