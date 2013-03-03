eval {
    # content #
    die 'rollback';
};
die $@ unless $@ =~ /rollback/;