package Test::CT::Assembly;
# ABSTRACT: Write tests files from *.ct.t files

use Moose;
use File::Find;
use YAML::Tiny;
use Data::Dumper;
use File::Spec::Functions qw/catdir catfile rel2abs abs2rel/;

has ct_dir => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);


has test_dir_output => (
    is => 'rw',
    isa => 'Str',
    required => 1
);

has check_syntax => (
    is => 'rw',
    isa => 'Bool',
    required => 0,
    default => sub {0}
);

sub write_tests {
    my ($self) = @_;

    $self->ct_dir(abs2rel($self->ct_dir));
    $self->test_dir_output(abs2rel( $self->test_dir_output ));

    die "test_dir_output does not exists ", $self->test_dir_output unless -e $self->test_dir_output;

    print "Writing to file ", catfile($self->test_dir_output, 'all-tests.t'), "\n";
    open(my $fh, '>:utf8', catfile($self->test_dir_output, 'all-tests.t'));

    die( catfile($self->ct_dir, 'config.yaml') . " not found!\n" ) unless -e catfile($self->ct_dir, 'config.yaml');

    my $yaml = YAML::Tiny->read( catfile($self->ct_dir, 'config.yaml') )->[0];

    die "YAML comfig invalid!\n" unless $yaml && ref $yaml eq 'HASH';

    print $fh 'use Test::CT;
use FindBin qw($Bin);
use lib "$Bin/../lib";

my $tester = Test::CT->instance;
my '.Data::Dumper->Sortkeys(1)->Dump([$yaml], [qw(test_ct_config)]).'
$tester->config($test_ct_config);
';

    print "Syntax checking is " . ($self->check_syntax ? 'on':'off') . "\n";

    my @boot;
    find({ wanted => sub {
        push @boot, $_ if (-f $_ && $_ =~ /\.ct\.t$/);
    }, no_chdir => 1 }, catdir($self->ct_dir, 'boot') );

    foreach my $boot_name (sort { $a cmp $b} @boot ){
        open my $r, '<:utf8', $boot_name;
        print $fh "# $boot_name\n";
        print $fh $self->_get_file_content($boot_name, may_check => 1);
    }

    my $wrapper_str = $self->_get_wrapper_str($self);

    my $tests = '';

    my @tests;
    find({ wanted => sub {
        push @tests, $_ if (-f $_ && $_ =~ /\.t$/);
    }, no_chdir => 1 }, catdir($self->ct_dir, 'tests') );

    foreach my $test_name (@tests){

        my $content = $self->_get_file_content($test_name, may_checkz => 1);
        my $copy = $wrapper_str;

        print $fh "# $test_name \n";
        print $fh "do { my \$ref = sub { \n".
            $content."\n\n};\n" .
            '$tester->add_test(Test::CT::TestFile->new( coderef => $ref, name => \'' . $test_name . "' ));\n};\n\n";

        $copy =~ s/\0wrapper\0/\n\$tester->run( name => '$test_name');\n/;
        print $fh "$copy\n\n";

    }

    print $fh "\n\$tester->finalize;\ndone_testing;\n";

    print "Done! now you can execute \$ prove -lr ", catfile($self->test_dir_output, 'all-tests.t'), " \n";

    return {
        tests => [ catfile( $self->test_dir_output, 'all-tests.t') ]
    };
}

sub _get_file_content {
    my ($self, $file, %options) = @_;

    if ($self->check_syntax && exists $options{may_check} ){
        my $mayok = `$^X -c '$file' 2>&1`;
        if ($mayok !~ /syntax OK\s+$/){
            $mayok =~ s/^/  /mg;
            die ("\n* Syntax error in $file:\n\n$mayok\n");
        }
    }

    my $content = '';

    print "Reading file ", $file, "...\n";
    open (my $r, '<:utf8', $file);
    $content .= $_ while <$r>;
    close $r;
    $content .= "\n" unless $content =~ /\n$/;
    return $content;
}

sub _get_wrapper_str {
    my ($self) = @_;

    my @wrappers;
    find({ wanted => sub {
        push @wrappers, $_ if (-f $_ && $_ =~ /\.ct\.t$/);
    }, no_chdir => 1 }, catdir($self->ct_dir, 'wrappers') );

    my @wrappers_list;
    my $wrapper_num = 0;
    foreach my $wrapper_name (sort { $a cmp $b} @wrappers ){
        my $wrapper = $self->_get_file_content($wrapper_name, may_check => 1);

        $wrapper =~ s/#\s+content\s+#/\0wrapper\0/i;
        $wrapper_num++;

        push @wrappers_list, $wrapper;
    }

    my $wrapper_str = "\0wrapper\0";
    for (my $i = $wrapper_num - 1; $i>=0; $i--){
        my $out = $wrappers_list[$i];
        $wrapper_str =~ s/\0wrapper\0/$out/;
    }
    return $wrapper_str;
}

1;

