package Test::CT::TestFile;
use Moo;

has name => (
    is => 'ro',
    required => 1,
);

has coderef => (
    is => 'ro',
    required => 1,
);

has has_run => (
    is => 'rw',
    default => sub {0}
);



1;

