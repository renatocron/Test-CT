package Test::CT;
# ABSTRACT: *Mix* of Test::More + Test::Reuse + Test::Routine, with *template* system.
use strict;
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

has current_test => (is => 'rw', isa => 'Str', default => sub { 'test name not defined!' });
has stash  => (is => 'rw', default => sub { {} });
has config => (is => 'rw', default => sub { {} });
has track => (is => 'rw', isa => 'Bool', default => sub { 1 });

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
        $self->current_test($name);
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
    my ($maybetrue, $test_name) = @_;
    my $self = Test::CT->instance;

    my $res = Test::More::ok( $maybetrue, $test_name);
    $self->push_log({
        func   => 'ok',
        arguments => [$maybetrue],
        result => $res,
        name   => $test_name
    });
}

sub is {
    my ($got, $expt, $test_name) = @_;

    my $self = Test::CT->instance;
    my $res = Test::More::is( $got, $expt, $test_name);
    $self->push_log({
        func   => 'is',
        arguments => [$got, $expt, $test_name],
        result => $res,
        name   => $test_name
    });

}

sub isnt {
    my ($got, $expt, $test_name) = @_;

    my $self = Test::CT->instance;
    my $res = Test::More::isnt( $got, $expt, $test_name);
    $self->push_log({
        func   => 'isnt',
        arguments => [$got, $expt, $test_name],
        result => $res,
        name   => $test_name
    });
}


sub like {
    my ($got, $expt, $test_name) = @_;

    my $self = Test::CT->instance;
    my $res = Test::More::like( $got, $expt, $test_name);
    $self->push_log({
        func   => 'like',
        arguments => [$got, $expt, $test_name],
        result => $res,
        name   => $test_name
    });
}

sub unlike {
    my ($got, $expt, $test_name) = @_;

    my $self = Test::CT->instance;
    my $res = Test::More::unlike( $got, $expt, $test_name);
    $self->push_log({
        func   => 'unlike',
        arguments => [$got, $expt, $test_name],
        result => $res,
        name   => $test_name
    });
}

sub is_deeply {
    my ($got, $expt, $test_name) = @_;

    my $self = Test::CT->instance;
    my $res = Test::More::is_deeply( $got, $expt, $test_name);
    $self->push_log({
        func   => 'is_deeply',
        arguments => [$got, $expt, $test_name],
        result => $res,
        name   => $test_name
    });
}

sub cmp_ok {
    my ($got, $op, $want, $test_name) = @_;

    my $self = Test::CT->instance;
    my $res = Test::More::cmp_ok( $got, $op, $want, $test_name );
    $self->push_log({
        func   => 'cmp_ok',
        arguments => [$got, $op, $want, $test_name],
        result => $res,
        name   => $test_name
    });
}

sub diag {
    my ($a) = @_;

    Test::More::diag( $a );
    Test::CT->instance->push_log({
        func   => 'diag',
        message => $a
    });
}

sub explain {
    my ($a) = @_;

    Test::More::explain( $a );
    Test::CT->instance->push_log({
        func   => 'explain',
        message => $a
    });
}

sub note {
    my ($a) = @_;
    Test::More::note( $a );
    Test::CT->instance->push_log({
        func   => 'note',
        message => $a
    });
}


sub push_log {
    my ($self, $param) = @_;

    $param->{name} = $self->current_test;
    push @{$self->stash->{_log}}, $param;
}

sub down_log_level {
    ...
}

sub up_log_level {
    ...
}

sub finalize {
    my ($self, $param) = @_;

    if ($self->track && ref $self->config->{log_writer} eq 'ARRAY'){

        foreach my $writer_conf (@{$self->config->{log_writer}}){

            $writer_conf->{path} = $self->config->{log_writers}{default_path}
                unless exists $writer_conf->{path};

            my $class = 'Test::CT::LogWriter::' . $writer_conf->{format};
            eval("use $class;");
            die $@ if $@;

            my $writer = $class->new( tester => $self );

            $writer->generate($writer_conf);
        }

    }

}


1;


__END__





=head1 SYNOPSIS

    use Test::CT;

    # get test singleton object
    my $tester = Test::CT->instance;

    # add your tests.. this may repeat sometimes in your file.
    do {
        my $ref = sub {
            # your testing code goes here
            my $user = { name => 'foo' };
            ok($user->{name}, 'looks have a name!');
            is($user->{name}, 'foo', 'user name is foo');
            isnt(1, 0, '1 isnt 0');

            $tester->stash->{user} = $user;

        };
        # add this code reference to tests list
        $tester->add_test(
            Test::CT::TestFile->new(
                coderef => $ref,
                name => 'ct/tests/001-name-you-give.t'
            )
        );
    };

    # then you can add another test that use $tester->stash->{user}
    # expecting it to be ok

    # run the tests!
    $tester->run( name => 'ct/tests/001-name-you-give.t');

    # this will not ran the test again
    $tester->run( name => 'ct/tests/001-name-you-give.t');

    # but you can force it
    $tester->run( name => 'ct/tests/001-name-you-give.t', force_exec => 1);

    $tester->run( like => 'name-.+'); # all tests name =~ /name-.+/

    $tester->run( llike => 'ct/tests/'); # all tests name =~ /^name-.+/

    # TODO
    $tester->run( like => qr/your regularexpr/);



Please see more in README in https://github.com/renatoaware/Test-CT


=head1 DESCRIPTION

Test-CT is a different way to you write your tests files.

Using commands of Test::More, writing separated tests files like Test::Aggregate::Nested
and using a stash to keep tracking of all tests for you write a simple (or not)
documentation for your project.


=method run(%conf)

Run the coderef of a Test::CT::TestFile

?name       => 'string' # find test by name
?like       => 'string' # find test by /$like/
?llike      => 'string' # find test by /^$like/
?force_exec => $boolean # true for execute tests even if already executed before


=method stash

It's like Catalyst stash. A simple hashref, so you can:

    $tester->stash( foo => 1, bar => 2)
    $tester->stash({ abc => 2});
    $tester->stash->{foo}++;

=method finalize

Instantiate all Test::CT::LogWriter::XXX from @{$self->config->{log_writer}} to generate documentation.

Should be called after all tests run.

=head1 CAVEATS

This is alpha software. But the interface will be stable, and changes will
make effort to keep back compatibility, even though major revisions.

=head1 SPONSORED BY

Aware - L<http://www.aware.com.br>

=cut
