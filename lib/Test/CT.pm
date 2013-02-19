package Test::CT;
our $VERSION = '0.01';
$VERSION = eval $VERSION;    ## no critic (BuiltinFunctions::ProhibitStringyEval)
use strict;
use MooseX::Singleton;
use Moose::Exporter;

use Test::CT::TestFile;

use Test::More qw//;

Moose::Exporter->setup_import_methods(
    as_is     => [
        qw /ok is isnt like unlike is_deeply diag note explain cmp_ok/,
        \&Test::More::use_ok,
        \&Test::More::require_ok,
        \&Test::More::todo_skip,
        \&Test::More::pass,
        \&Test::More::fail,
        \&Test::More::plan,
        \&Test::More::done_testing,
        \&Test::More::can_ok,
        \&Test::More::isa_ok,
        \&Test::More::new_ok,
        \&Test::More::subtest,
        \&Test::More::BAIL_OUT,
    ],
    also      => 'Moose',
);

has stash => (is => 'rw', default => sub { {} });

has tests => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => 'ArrayRef[Test::CT::TestFile]',
    default => sub { [] },
    handles => {
        all_tests    => 'elements',
        add_test     => 'push',
        map_tests    => 'map',
        find_test    => 'first',
        grep_test    => 'grep',
        count_tests  => 'count',
    },
);


# NOTE: copy from Test::More.pm
# Can't use Carp because it might cause use_ok() to accidentally succeed
# even though the module being used forgot to use Carp.  Yes, this
# actually happened.
sub _carp {
    my( $file, $line ) = ( caller(1) )[ 1, 2 ];
    return warn @_, " at $file line $line\n";
}

sub _croak {
    my( $file, $line ) = ( caller(1) )[ 1, 2 ];
    die(@_, " at $file line $line\n");
}
# END OF NOTE


around stash => sub {
    my $orig = shift;
    my $c = shift;
    my $stash = $orig->($c);
    if (@_) {
        my $new_stash = @_ > 1 ? {@_} : $_[0];
        croak('stash takes a hash or hashref') unless ref $new_stash;
        foreach my $key ( keys %$new_stash ) {
          $stash->{$key} = $new_stash->{$key};
        }
    }

    return $stash;
};


=pod
 ?name  => str
 ?like  => str        /expression/
 ?llike => str        /^expression/
 ?force_exec => bool
=cut
sub run {
    my ($self, %param) = @_;

    if (exists $param{name} ){
        my $item = $self->find_test( sub { $_->name eq $param{name} });
        return fail("cant find test $param{name}...") unless defined $item;

        $self->_run_test(\%param, $item);
    }

    if (exists $param{like} || exists $param{llike} ){
        my $regexp = exists $param{like} ? qr/$param{like}/ : qr/^$param{llike}/;

        my @items = $self->grep_test( sub { $_->name =~ $regexp });
        $self->_run_test(\%param, $_) for @items;
    }

    return 1;
}

sub _run_test {
    my ($self, $param, $item) = @_;

    my $name = $item->name;
    my $do_exec = !$item->has_run || $param->{force_exec};

    # NOTE tests don't ran more than one time, even if fail
    $item->has_run(1);
    if ($do_exec){
        eval{
            $item->coderef->();
        };

        if ($@){
            $item->error($@);
            return fail("$name died with error $@");
        }
    }else{
        diag("Test $name already run");
    }
    return 1;

}

sub ok {
    my ($a, $test_name) = @_;

    _croak('Singleton Test instance not initialized!') unless defined Test::CT->instance;

    Test::More::ok( $a, $test_name);
}

sub is {
    my ($got, $expt, $test_name) = @_;

    _croak('Singleton Test instance not initialized!') unless defined Test::CT->instance;


    Test::More::is( $got, $expt, $test_name);
}

sub isnt {
    my ($got, $expt, $test_name) = @_;

    _croak('Singleton Test instance not initialized!') unless defined Test::CT->instance;


    Test::More::isnt( $a, $expt, $test_name);
}


sub like {
    my ($got, $expt, $test_name) = @_;
    _croak('Singleton Test instance not initialized!') unless defined Test::CT->instance;

    Test::More::like( $got, $expt, $test_name);
}

sub unlike {
    my ($got, $expt, $test_name) = @_;
    _croak('Singleton Test instance not initialized!') unless defined Test::CT->instance;

    Test::More::unlike( $got, $expt, $test_name);
}

sub is_deeply {
    my ($got, $expt, $test_name) = @_;
    _croak('Singleton Test instance not initialized!') unless defined Test::CT->instance;

    Test::More::is_deeply( $got, $expt, $test_name);
}

sub cmp_ok {
    my ($got,$op, $expt, $test_name) = @_;
    _croak('Singleton Test instance not initialized!') unless defined Test::CT->instance;

    Test::More::cmp_ok( $got,$op, $expt, $test_name );
}

sub diag {
    my ($a) = @_;
    _croak('Singleton Test instance not initialized!') unless defined Test::CT->instance;

    Test::More::diag( $a );
}

sub explain {
    my ($a) = @_;
    _croak('Singleton Test instance not initialized!') unless defined Test::CT->instance;
    Test::More::explain( $a );
}

sub note {
    my ($a) = @_;
    _croak('Singleton Test instance not initialized!') unless defined Test::CT->instance;
    Test::More::note( $a );
}


1;

