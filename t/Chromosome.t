#!/bin/env perl
use v5.10;
use strict;
use Test::More;

use Chromosome;

subtest 'default values' => sub {
    my $chromosome = Chromosome->new({
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
    is($chromosome->decimal, 0);
    is(length $chromosome->key, 8 * 8);

    my $weights = $chromosome->weights;

    is($weights->{position},              1);
    is($weights->{score},                 -1);
    is($weights->{empty_tiles},           127);
    is($weights->{tile_value},            85);
    is($weights->{tile_neighbours},       0);
    is($weights->{tile_empty_neighbours}, -8);
    is($weights->{tile_min_distance},     0);
    is($weights->{tile_max_distance},     64);
};

subtest 'more bits' => sub {
    my $chromosome = Chromosome->new({
        bits => 10,
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
    is($chromosome->decimal, 0);
    is(length $chromosome->key, 8 * 10);

    my $weights = $chromosome->weights;

    is($weights->{position},              1);
    is($weights->{score},                 -1);
    is($weights->{empty_tiles},           511);
    is($weights->{tile_value},            341);
    is($weights->{tile_neighbours},       0);
    is($weights->{tile_empty_neighbours}, -16);
    is($weights->{tile_min_distance},     0);
    is($weights->{tile_max_distance},     256);
};

subtest 'less bits' => sub {
    my $chromosome = Chromosome->new({
        bits => 4,
        genes => [
            1,0,0,1,
            0,0,0,0,
            0,0,0,1,
            0,0,1,0,
            0,0,1,1,
            0,1,0,0,
            0,1,0,1,
            0,1,1,0,
        ]
    });

    is($chromosome->bits, 4);
    is($chromosome->decimal, 0);
    is(length $chromosome->key, 8 * 4);

    my $weights = $chromosome->weights;

    is($weights->{position},              -1);
    is($weights->{score},                 0);
    is($weights->{empty_tiles},           1);
    is($weights->{tile_value},            2);
    is($weights->{tile_neighbours},       3);
    is($weights->{tile_empty_neighbours}, 4);
    is($weights->{tile_min_distance},     5);
    is($weights->{tile_max_distance},     6);
};

subtest 'with 2 decimals' => sub {
    my $chromosome = Chromosome->new({
        decimal => 2,
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
    is($chromosome->decimal, 2);
    is(length $chromosome->key, 8 * 8);

    my $weights = $chromosome->weights;

    is($weights->{position},              0.01);
    is($weights->{score},                 -0.01);
    is($weights->{empty_tiles},           1.27);
    is($weights->{tile_value},            0.85);
    is($weights->{tile_neighbours},       0);
    is($weights->{tile_empty_neighbours}, -0.08);
    is($weights->{tile_min_distance},     0);
    is($weights->{tile_max_distance},     0.64);
};

subtest 'with 1 decimal and 10 bits' => sub {
    my $chromosome = Chromosome->new({
        decimal => 1,
        bits => 10,
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
    is(length $chromosome->key, 8 * 10);

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
