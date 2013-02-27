package Test::CT::LogWriter::Markdown;
# ABSTRACT: Write tests results in Markdown
use Moose;
use Data::Dumper;

has tester => (
    is => 'ro',
    isa =>'Test::CT',
    weak_ref => 1
);

sub generate {
    my ($self) = @_;

    my $path = $self->tester->config->{log_writter}{path} . '/';
    mkdir $path, 0666 or die "cant create $path $!" unless -d $path;

    my $dumper = Data::Dumper->Sortkeys(1); #->Dump([$yaml], [qw(test_ct_config)]).'

    print "log not found in stash!\n" and return
        unless exists $self->tester->stash->{_log} &&
                  ref $self->tester->stash->{_log} eq 'ARRAY';

    my $struct = {};

    foreach my $item ( @{ $self->tester->stash->{_log} } ){
        $item = $self->_process_item($item);
        push @{$struct->{$item->{name}}}, $item
            if defined $item;
    }
    use DDP; p $struct;

    #open(my $fh, ':utf8', $path . 'all-tests.md' );
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
            '**' . $item->{arguments}[1] . "**\n" : '') .
            '    ok(' .
                join(',', @{$item->{arguments}} ) .
            ') resulted in ' . _tf($item) . "\n";

    }elsif ($item->{func} =~ /^is(?:nt)?$/){

    }elsif ($item->{func} =~ /^(?:un)?like$/){

    }elsif ($item->{func} eq 'cmp_ok'){

    }elsif ($item->{func} eq 'is_deeply'){

    }elsif ($item->{func} =~ /(note|diag|explain)/){

    }else{
        # unsupported
        return undef;
    }

    return $item;
}

1;

