Test-CT
=======

Simple test framework to write tests based on your rules. To you DRY your tests

perl $dir_to_ct/bin/writetest.pl
Writing to file t/all-tests.t
Reading file ct/boot/01-instanciar_catalyst.ct.t...
Reading file ct/boot/02-load_schema.ct.t...
Reading file ct/wrappers/001-schema-begin.ct.t...
Reading file ct/tests/001-iei.t...
Reading file ct/tests/002-count_users.t...
Done! now you can execute $ prove -lr t/all-tests.t


export PERL5LIB="$PERL5LIB:$dir_to_ct/lib"

prove -lr t/all-tests.t
t/all-tests.t .. 1/? Printing in line 49 of t/all-tests.t:
\ {
    testes:  1
}
# Test ct/tests/001-iei.t already run
# Test ct/tests/001-iei.t already run
t/all-tests.t .. ok
All tests successful.
Files=1, Tests=15,  2 wallclock secs ( 0.02 usr  0.00 sys +  1.79 cusr  0.05 csys =  1.86 CPU)
Result: PASS
