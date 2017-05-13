#!/bin/env perl
use v5.10;
use strict;
use Test::More;

use Wheel;
use Chromosome::Dummy;

subtest 'internals' => sub {
    my $generation = [
        Chromosome::Dummy->new({ key => 'a', fitness => 10 }),
        Chromosome::Dummy->new({ key => 'b', fitness => 2 }),
        Chromosome::Dummy->new({ key => 'c', fitness => 1 }),
    ];

    my $wheel = Wheel->new({ chromosomes => $generation });

    is($wheel->_get(0)->key, 'a');
    is($wheel->_get(0.76)->key, 'a');
    is($wheel->_get(0.77)->key, 'b');
    is($wheel->_get(0.92)->key, 'b');
    is($wheel->_get(0.93)->key, 'c');
    is($wheel->_get(1)->key, 'c');
};

done_testing();
