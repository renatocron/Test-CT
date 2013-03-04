Test-CT
=======

This git contains the code of Test-CT `version 0.1`.

Test-CT is a different way to you write your tests files.

Using commands of Test::More, writing separated tests files like Test::Aggregate::Nested
and using a stash to keep tracking of all tests for you write a simple (or not)
documentation for your project.


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


To see this in action, please execute (you need have dependencies installed as well!):

    $ git clone git://github.com/renatoaware/Test-CT.git
    $ cd Test-CT
    $ cd etc
    $ mkdir test_out
    $ perl  -I../lib/ ../bin/ct-build -in ct/ -out test_out/

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


Here are the currently are dependencies, but dzil may keep cpan builds up to date:

* Moose
* MooseX::Singleton
* Moose::Exporter
* Test::More

Please see ct-build / ct-init man page to more info about it.

    $ man ct-init

    $ man ct-build


## CAVERATS

Currently, you can not use __END__ or __DATA__ on your tests scripts. Nor do "use strict" by yourself.

All tests scripts outputs begin `use Test::CT` that do a `use Moose`, so it already are strict / warnings;


## TODO

* support to more log outputs (like interative HTML)
* more than one test output. (eg: group of tests)
* exemple of custom LogWriter for CRUD Catalyst REST API
* __DATA__ and __END__
* Test::CT::LogWriter::Swagger ?

## AUTHOR

Renato Cron / [RENTOCRON @ metacpan](https://metacpan.org/author/RENTOCRON)

## SUPPORT

IRC:

    Join #sao-paulo.pm on irc.perl.org [this is a portuguese channel, but you can speak in english with us!]

## SPONSORED BY

Aware - [http://www.aware.com.br](http://www.aware.com.br)


## LICENSE

This software is copyright (c) 2013 by Renato Cron.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.