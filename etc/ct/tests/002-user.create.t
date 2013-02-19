
# supposed you created a user somewhere and
# save the result on $user;

my $user = {
    id   => 1,
    name => 'foo',
};
diag("creating user id..");
is($user->{id}, 1, 'user id is really 1');

$tester->stash->{user} = $user;

