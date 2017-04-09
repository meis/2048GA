#!/bin/env perl
use v5.10;
use strict;
use Test::More;

use Minion::Chromosome;

subtest 'bits2weight' => sub {
    is(Minion::Chromosome::bits2weight(0,0,0,0,0), 1);
    is(Minion::Chromosome::bits2weight(0,0,0,0,1), 5);
    is(Minion::Chromosome::bits2weight(0,0,0,1,0), 10);
    is(Minion::Chromosome::bits2weight(0,0,0,1,1), 50);

    is(Minion::Chromosome::bits2weight(0,0,1,0,0), 100);
    is(Minion::Chromosome::bits2weight(0,0,1,0,1), 500);
    is(Minion::Chromosome::bits2weight(0,0,1,1,0), 1000);
    is(Minion::Chromosome::bits2weight(0,0,1,1,1), 5000);

    is(Minion::Chromosome::bits2weight(0,1,0,0,0), 1);
    is(Minion::Chromosome::bits2weight(0,1,0,0,1), 1/5);
    is(Minion::Chromosome::bits2weight(0,1,0,1,0), 1/10);
    is(Minion::Chromosome::bits2weight(0,1,0,1,1), 1/50);

    is(Minion::Chromosome::bits2weight(0,1,1,0,0), 1/100);
    is(Minion::Chromosome::bits2weight(0,1,1,0,1), 1/500);
    is(Minion::Chromosome::bits2weight(0,1,1,1,0), 1/1000);
    is(Minion::Chromosome::bits2weight(0,1,1,1,1), 1/5000);

    is(Minion::Chromosome::bits2weight(1,0,0,0,0), -1);
    is(Minion::Chromosome::bits2weight(1,0,0,0,1), -5);
    is(Minion::Chromosome::bits2weight(1,0,0,1,0), -10);
    is(Minion::Chromosome::bits2weight(1,0,0,1,1), -50);

    is(Minion::Chromosome::bits2weight(1,0,1,0,0), -100);
    is(Minion::Chromosome::bits2weight(1,0,1,0,1), -500);
    is(Minion::Chromosome::bits2weight(1,0,1,1,0), -1000);
    is(Minion::Chromosome::bits2weight(1,0,1,1,1), -5000);

    is(Minion::Chromosome::bits2weight(1,1,0,0,0), -1);
    is(Minion::Chromosome::bits2weight(1,1,0,0,1), -1/5);
    is(Minion::Chromosome::bits2weight(1,1,0,1,0), -1/10);
    is(Minion::Chromosome::bits2weight(1,1,0,1,1), -1/50);

    is(Minion::Chromosome::bits2weight(1,1,1,0,0), -1/100);
    is(Minion::Chromosome::bits2weight(1,1,1,0,1), -1/500);
    is(Minion::Chromosome::bits2weight(1,1,1,1,0), -1/1000);
    is(Minion::Chromosome::bits2weight(1,1,1,1,1), -1/5000);
};

subtest 'weights' => sub {
    my $chromosome = Minion::Chromosome->new({
        bits => [
            1, 0, 1, 1, 1,
            0, 1, 1, 1, 1,
            0, 1, 1, 0, 1,
            0, 0, 0, 0, 1,
            1, 1, 0, 1, 0,
            1, 1, 0, 1, 0,
            0, 0, 1, 0, 1,
            1, 1, 0, 0, 1,
        ]
    });

    my $expected_weights = {
        position              => -5000,
        score                 => 1/5000,
        empty_tiles           => 1/500,
        tile_value            => 5,
        tile_neighbours       => -1/10,
        tile_empty_neighbours => -1/10,
        tile_min_distance     => 500,
        tile_max_distance     => -1/5,
    };

    is_deeply($chromosome->weights, $expected_weights);
};

done_testing();
