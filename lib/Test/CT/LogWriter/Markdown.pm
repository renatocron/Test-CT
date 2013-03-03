package Test::CT::LogWriter::Markdown;
# ABSTRACT: Write tests results in Markdown
use Moose;
use Data::Dumper;

has tester => (
    is => 'ro',
    isa =>'Test::CT',
    weak_ref => 1
);

has _dumper => (
    is => 'ro',
    isa => 'Any',
    lazy => 1,
    default => sub {
        Data::Dumper->Sortkeys(1); #->Dump([$yaml], [qw(test_ct_config)]).'
    }
);

sub generate {
    my ($self) = @_;

    my $path = $self->tester->config->{log_writter}{path} . '/';
    mkdir $path, 0666 or die "cant create $path $!" unless -d $path;

    print "log not found in stash!\n" and return
        unless exists $self->tester->stash->{_log} &&
                  ref $self->tester->stash->{_log} eq 'ARRAY';

    my $struct = {};

    foreach my $item ( @{ $self->tester->stash->{_log} } ){
        $item = $self->_process_item($item);
        push @{$struct->{$item->{name}}}, $item
            if defined $item;
    }

    open(my $fh, '>:utf8', $path . 'all-tests.md' ) or die "$! for $path/all-tests.md";

    while (my ($test, $tests) = each %$struct){

        print $fh "# $test\n\n";

        print $fh $_->{md} . "\n" foreach (@{$tests});
    }
    #use DDP; p $path;

}

sub _tf {
    return shift->{result} ? 'success' : 'error';
}

sub _process_item {
    my ($self, $item) = @_;

    die "func not defined!" unless exists $item->{func};
    if ($item->{func} eq 'ok'){

        $item->{md} = (@{$item->{arguments}} == 2 ?
            '**' . $item->{arguments}[1] . "** " : '') .
            '`ok(' .
                join(', ', @{$item->{arguments}} ) .
            ')` resulted in ' . _tf($item) . "\n";

    }elsif ($item->{func} =~ /^is(?:nt)?$/){

        $item->{md} = (@{$item->{arguments}} == 3 ?
            '**' . $item->{arguments}[2] . "** " : '') .
            '`' . $item->{func}.'(' .
                $item->{arguments}[0] . ', ' . $item->{arguments}[1] .
            ')` resulted in ' . _tf($item) . "\n";

    }elsif ($item->{func} =~ /^(?:un)?like$/){

        $item->{md} = (@{$item->{arguments}} == 3 ?
            '**' . $item->{arguments}[2] . "** " : '') .
            '`' . $item->{func}.'(q{' .
                 $item->{arguments}[0] . '}, ' . $item->{arguments}[1] .
            ')` resulted in ' . _tf($item) . "\n";

    }elsif ($item->{func} eq 'cmp_ok'){

        $item->{md} = (@{$item->{arguments}} == 4 ?
            '**' . $item->{arguments}[3] . "** " : '') .
            '`cmp_ok(' . $item->{arguments}[0] . ' ' . $item->{arguments}[1] . ' ' . $item->{arguments}[2] . ') ? 1 : 0' .
            '` resulted in ' . _tf($item) . "\n";

    }elsif ($item->{func} eq 'is_deeply'){

        my $name = @{$item->{arguments}} == 3 ? $item->{arguments}[2] : '';

        my $code = $self->_dumper->Dump( [ $item->{arguments}[0], $item->{arguments}[1] ], ['want','expected'] );
        $code =~ s/^/\t/gm;

        $item->{md} = ($name ?
            '**' . $name . "**\n\n" : '') .
            $code .
            '`is_deeply( $want, $expected )` ' .
            'resulted in ' . _tf($item) . "\n";

    }elsif ($item->{func} =~ /(note|diag|explain)/){

        my $code = $item->{message};
        $code =~ s/^/\> /gm;

        $item->{md} = "$code\n";

    }else{
        # unsupported
        return undef;
    }

    return $item;
}

1;

