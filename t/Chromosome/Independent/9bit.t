#!/bin/env perl
use v5.10;
use strict;
use Test::More;

use Chromosome::Independent::9bit;

subtest '9 bits' => sub {
    my $chromosome = Chromosome::Independent::9bit->new({
        genes => [
            0,0,0,0,0,0,0,0,1,
            1,0,0,0,0,0,0,0,1,
            0,1,1,1,1,1,1,1,1,
            0,1,0,1,0,1,0,1,0,
            0,0,0,0,0,0,0,0,0,
            1,0,0,0,0,1,0,0,0,
            1,0,0,0,0,0,0,0,0,
            0,1,0,0,0,0,0,0,0,
        ]
    });

    is($chromosome->bits, 9);
    is($chromosome->decimal, 0);

    my $weights = $chromosome->weights;

    is($weights->{position},              1);
    is($weights->{score},                 -1);
    is($weights->{empty_tiles},           255);
    is($weights->{tile_value},            170);
    is($weights->{tile_neighbours},       0);
    is($weights->{tile_empty_neighbours}, -8);
    is($weights->{tile_min_distance},     0);
    is($weights->{tile_max_distance},     128);
};

done_testing();
