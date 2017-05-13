#!/bin/env perl
use v5.10;
use strict;
use Test::More;

use Chromosome::Independent::8bit1decimal;

subtest '8 bits, 1 decimal' => sub {
    my $chromosome = Chromosome::Independent::8bit1decimal->new({
        genes => [
            0,0,0,0,0,0,0,1,
            1,0,0,0,0,0,0,1,
            0,1,1,1,1,1,1,1,
            0,1,0,1,0,1,0,1,
            0,0,0,0,0,0,0,0,
            1,0,0,0,1,0,0,0,
            1,0,0,0,0,0,0,0,
            0,1,0,0,0,0,0,0,
        ]
    });

    is($chromosome->bits, 8);
    is($chromosome->decimal, 1);

    my $weights = $chromosome->weights;

    is($weights->{position},              0.1);
    is($weights->{score},                 -0.1);
    is($weights->{empty_tiles},           12.7);
    is($weights->{tile_value},            8.5);
    is($weights->{tile_neighbours},       0);
    is($weights->{tile_empty_neighbours}, -0.8);
    is($weights->{tile_min_distance},     0);
    is($weights->{tile_max_distance},     6.4);
};

done_testing();
