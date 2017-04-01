#!/bin/env perl
use v5.10;
use strict;
use Test::More;
use Game2048::Engine;

subtest 'create' => sub {
    ok(Game2048::Engine->new);
};

subtest 'move' => sub {
    my $e = Game2048::Engine->new;
    ok($e->move('left'));
};

done_testing();
