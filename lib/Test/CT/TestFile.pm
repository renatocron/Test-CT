package Test::CT::TestFile;
use Moose;

has name => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has coderef => (
    is => 'ro',
    isa => 'Any',
    required => 1,
);

has has_run => (
    is => 'rw',
    isa => 'Bool',
    default => sub {0}
);

has error => (
    is => 'ro',
    isa => 'Str',
);



1;

