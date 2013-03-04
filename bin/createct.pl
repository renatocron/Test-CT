#!/usr/bin/perl
# PODNAME: ctupdate

use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Getopt::Long;
use YAML::Tiny;

my $ct_dir;

GetOptions(
    "in=s"   => \$ct_dir
) or exit;


$ct_dir ||= ( -e 'ct/' ? 'ct/' : ( -e '../ct/' ? '../ct/' : (-e $ARGV[0] ? $ARGV[0] : die("cant found ct_dir")) ));

mkdir $ct_dir or die "Cant create $ct_dir $@" unless -d $ct_dir;

mkdir $ct_dir . '/boot';
mkdir $ct_dir . '/tests';
mkdir $ct_dir . '/wrappers';

die ("config already exists!\n") if -e $ct_dir.'/config.yaml';

my $conf = {};

while (!exists $conf->{log_writter}{format}){
    print "Set your LogWritter format [Markdown] ";
    my $maybe = <>;
    chop($maybe);
    $maybe ||='Markdown';
    if ($maybe =~ /^Markdown$/){
        $conf->{log_writter}{format} = $maybe;
    }else{
        print "invalid option $maybe\n";
    }
}



print "Set your LogWritter path [testsdoc/] ";
my $maybe = <>;
chop($maybe);
$maybe ||='testsdoc/';
$conf->{log_writter}{path} = $maybe;


my $yaml = YAML::Tiny->new;

$yaml->[0] = $conf;
$yaml->write( $ct_dir.'/config.yaml' );

print "Config write in $ct_dir/config.yaml\n";

