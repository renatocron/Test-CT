Test-CT
=======

This archive contains the distribution Test-CT,
version 0.1:


  *Mix* of Test::More + Test::Reuse + Test::Routine, with *template* system.

  or

  Simple test framework to write tests based on your rules. To you DRY your tests;


SYNOPSIS
--------

Test::CT is a class for *instruct* how your tests will run.

How it works:

    use Test::CT;

    # it is a singleton object
    my $tester = Test::CT->instance;



    my $ref = sub {
        # your testing code goes here

        $tester->stash->{what_you_want} = $something;
    };

    # add this code reference to tests list, with a name.
    $tester->add_test(
        Test::CT::TestFile->new(
            coderef => $ref,
            name => 'name you want'
        )
    );

    # then repeat it until you added all tests

    # run the tests!
    $tester->run( name => 'name you want');

    $tester->run( name => 'name you want'); # this will not run test again!


Like Test::More, Test::CT gives to the following methods:

    ok
    cmp_ok
    is isnt
    like unlike
    is_deeply
    diag
    note
    explain

Other methods of Test::More are also avaliable, but nothing are saved to documentation use.

Test::CT will get the data passed to the tests to write a file with all tests input + output to keep
your application "documented". This isn't a true documentation, but it can help
a lot when you are building APIs, so you can automate generation of endpoints params and outputs (because you have all your endpoints documented, aren't you? Good! )

This modules also provide a class to build this test file to yourself!

Given this directory struct:

    ./ct/boot:
        01-load-heavy-things.ct.t
        02-do-another-thing-after-01.ct.t

    ./ct/wrappers:
        001-then-schema-begin.ct.t

    ./ct/tests:
        001-first-test.t
        002-user.create.t
        ./user:
            01-roles.create.t


To see this in action, execute (you need have dependencies installed as well!):

    $ git clone git://github.com/renatoaware/Test-CT.git
    $ cd Test-CT
    $ cd etc
    $ mkdir test_out
    $ perl  -I../lib/ ../bin/writetest.pl -in ct/ -out test_out/

    output:
        Writing to file test_out/all-tests.t
        Reading file ct/boot/01-load-heavy-things.ct.t...
        Reading file ct/boot/02-do-another-thing-after-01.ct.t...
        Reading file ct/wrappers/001-schema-begin.ct.t...
        Reading file ct/tests/001-first-test.t...
        Reading file ct/tests/002-user.create.t...
        Reading file ct/tests/user/01-roles.create.t...
        Done! now you can execute $ prove -lr test_out/all-tests.t

    then your test script will be on test_out/all-tests.t !

    Please note that, if you want to run tests without Test::CT installed, you should use this instead:

    $ prove -I../lib -lr test_out/all-tests.t


dependencies are currently:

    Test::More
    Moose

This software is copyright (c) 2013 by Renato Cron.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
