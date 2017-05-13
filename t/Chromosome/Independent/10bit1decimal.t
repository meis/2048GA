#!/bin/env perl
use v5.10;
use strict;
use Test::More;

use Chromosome::Independent::10bit1decimal;

subtest '10 bits, 1 decimal' => sub {
    my $chromosome = Chromosome::Independent::10bit1decimal->new({
        genes => [
            0,0,0,0,0,0,0,0,0,1,
            1,0,0,0,0,0,0,0,0,1,
            0,1,1,1,1,1,1,1,1,1,
            0,1,0,1,0,1,0,1,0,1,
            0,0,0,0,0,0,0,0,0,0,
            1,0,0,0,0,1,0,0,0,0,
            1,0,0,0,0,0,0,0,0,0,
            0,1,0,0,0,0,0,0,0,0,
        ]
    });

    is($chromosome->bits, 10);
    is($chromosome->decimal, 1);

    my $weights = $chromosome->weights;

    is($weights->{position},              0.1);
    is($weights->{score},                 -0.1);
    is($weights->{empty_tiles},           51.1);
    is($weights->{tile_value},            34.1);
    is($weights->{tile_neighbours},       0);
    is($weights->{tile_empty_neighbours}, -1.6);
    is($weights->{tile_min_distance},     0);
    is($weights->{tile_max_distance},     25.6);
};

done_testing();
