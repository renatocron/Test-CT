package Test::CT::TestFile;
# ABSTRACT: Test::CT::TestFile keep status of a piece of a test
# VERSION 0.01
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

