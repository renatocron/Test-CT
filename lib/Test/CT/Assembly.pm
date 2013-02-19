package Test::CT::Assembly;
use Moo;


has ct_dir => (
    is => 'ro',
    required => 1,
);


has test_dir_output => (
    is => 'ro',
    required => 0,
    default => sub {
        -e 't/' ? 't/' :
            -e '../t/' ? '../t/' : die ("set test_dir_output");
    }
);


sub write_tests {
    my ($self) = @_;

    open(my $fh, '>:utf8', $self->test_dir_output . 'all-tests.t');

    print $fh 'use Test::CT;
use FindBin qw($Bin);
use lib "$Bin/../lib";

my $tester = Test::CT->instance;
';

    my @boot = glob($self->ct_dir. 'boot/*.ct.t');
    foreach my $boot_name (sort { $a cmp $b} @boot ){
        open my $r, '<:utf8', $boot_name;
        print $fh "# $boot_name\n";
        print $fh $self->_get_file_content($boot_name);
    }

    my $wrapper_str = $self->_get_wrapper_str($self);

    my $tests = '';

    my @tests = glob($self->ct_dir. 'tests/*.t');
    foreach my $test_name (@tests){

        my $content = $self->_get_file_content($test_name);
        my $copy = $wrapper_str;

        print $fh "# $test_name \n";
        print $fh "do { my \$ref = sub { \n".
            $content."\n\n};\n" .
            '$tester->add_test(Test::CT::TestFile->new( coderef => $ref, name => \'' . $test_name . "' ));\n};\n\n";

        $copy =~ s/\0wrapper\0/\n\$tester->run( name => '$test_name');\n/;
        print $fh "$copy\n\n";

    }

    print $fh "\ndone_testing;\n";


    return 1;
}

sub _get_file_content {
    my ($self, $file) = @_;
    my $content = '';
    open (my $r, '<:utf8', $file);
    $content .= $_ while <$r>;
    close $r;
    $content .= "\n" unless $content =~ /\n$/;
    return $content;
}

sub _get_wrapper_str {
    my ($self) = @_;

    my @wrappers = glob($self->ct_dir. 'wrappers/*.ct.t');
    my @wrappers_list;
    my $wrapper_num = 0;
    foreach my $wrapper_name (sort { $a cmp $b} @wrappers ){
        my $wrapper = $self->_get_file_content($wrapper_name);

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

