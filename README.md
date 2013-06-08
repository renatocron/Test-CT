Test-CT
=======

This git contains the code of Test-CT `version 0.142`.

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

    $tester->run( name => 'name you want'); # the subref will not be called again, only if you


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

    ./ct/config.yaml


To see this in action, please execute (you need have dependencies installed as well!):

    $ git clone git://github.com/renatoaware/Test-CT.git
    $ cd Test-CT/test-ct/
    $ mkdir etc/test_out
    $ perl -Ilib/ bin/ct-build -dir etc/ct/ -out etc/test_out/

    output:

        Writing to file etc/test_out/all-tests.t
        Syntax checking is on
        Reading file etc/ct/boot/01-load-heavy-things.ct.t...
        Reading file etc/ct/boot/02-do-another-thing-after-01.ct.t...
        Reading file etc/ct/wrappers/001-schema-begin.ct.t...
        Reading file etc/ct/tests/002-user.create.t...
        Reading file etc/ct/tests/001-first-test.t...
        Reading file etc/ct/tests/user/01-roles.create.t...
        Done! now you can execute $ prove -lr etc/test_out/all-tests.t

    then your test script will be on test_out/all-tests.t !

    you can also execute:

    $ perl -Ilib/ bin/ct-build -dir etc/ct/ -out etc/test_out/ -prove

    output:
        ...
        auto-execute prove on!
        executing prove -lv for etc/test_out/all-tests.t...
        # creating user id..
        etc/test_out/all-tests.t ..
        ok 1 - user id is really 1
        ok 2 - 1 looks ok
        ok 3 - 1 is 1
        ok 4 - 1 isnt 0
        ok 5 - start and finish with a
        ok 6 - dont start and finish with a
        ok 7 - 1 == 1.0
        ok 8 - is_deeply ok
        ok 9 - 1 is ok!
        1..9
        ok
        All tests successful.
        Files=1, Tests=9,  0 wallclock secs ( 0.01 usr  0.01 sys +  0.23 cusr  0.00 csys =  0.25 CPU)
        Result: PASS


After this, `etc/test_out/doc/all-tests.md` will be (re)written with tests results.

You can see one example [here, docs/examples/logwritter-markdown-sample.md](https://github.com/renatoaware/Test-CT/blob/master/docs/examples/logwritter-markdown-sample.md "Markdown Sample")


Here are the currently are dependencies, but dzil may keep cpan builds up to date:

* Moose
* MooseX::Singleton
* Moose::Exporter
* Test::More

Please see ct-build / ct-init man page to more info about it.

    $ man ct-init

    $ man ct-build


## CAVERATS

### __END__ and __DATA__

Currently, if you write `__END__` or `__DATA__` in your tests scripts, all text bellow `__END__` will be lost, even `__DATA__`.

Also, when `__DATA__` is present, then `$data_content` will exists and hold the data content (O'RLY?).

## Hints

All tests scripts outputs begin `use Test::CT` that do a `use Moose`, so it already are strict / warnings;


## TODO

* support to more log outputs (like interative HTML)
* more than one test output. (eg: group of tests)
* exemple of custom LogWriter for CRUD Catalyst REST API
* Test::CT::LogWriter::Swagger ?
* timings

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