#!/bin/env perl
use v5.10;
use strict;
use Test::More;

use Chromosome::40Bits;

subtest '_gene2weight' => sub {
    is(Chromosome::40Bits::_gene2weight(0,0,0,0,0), 1);
    is(Chromosome::40Bits::_gene2weight(0,0,0,0,1), 5);
    is(Chromosome::40Bits::_gene2weight(0,0,0,1,0), 10);
    is(Chromosome::40Bits::_gene2weight(0,0,0,1,1), 50);

    is(Chromosome::40Bits::_gene2weight(0,0,1,0,0), 100);
    is(Chromosome::40Bits::_gene2weight(0,0,1,0,1), 500);
    is(Chromosome::40Bits::_gene2weight(0,0,1,1,0), 1000);
    is(Chromosome::40Bits::_gene2weight(0,0,1,1,1), 5000);

    is(Chromosome::40Bits::_gene2weight(0,1,0,0,0), 1);
    is(Chromosome::40Bits::_gene2weight(0,1,0,0,1), 1/5);
    is(Chromosome::40Bits::_gene2weight(0,1,0,1,0), 1/10);
    is(Chromosome::40Bits::_gene2weight(0,1,0,1,1), 1/50);

    is(Chromosome::40Bits::_gene2weight(0,1,1,0,0), 1/100);
    is(Chromosome::40Bits::_gene2weight(0,1,1,0,1), 1/500);
    is(Chromosome::40Bits::_gene2weight(0,1,1,1,0), 1/1000);
    is(Chromosome::40Bits::_gene2weight(0,1,1,1,1), 1/5000);

    is(Chromosome::40Bits::_gene2weight(1,0,0,0,0), -1);
    is(Chromosome::40Bits::_gene2weight(1,0,0,0,1), -5);
    is(Chromosome::40Bits::_gene2weight(1,0,0,1,0), -10);
    is(Chromosome::40Bits::_gene2weight(1,0,0,1,1), -50);

    is(Chromosome::40Bits::_gene2weight(1,0,1,0,0), -100);
    is(Chromosome::40Bits::_gene2weight(1,0,1,0,1), -500);
    is(Chromosome::40Bits::_gene2weight(1,0,1,1,0), -1000);
    is(Chromosome::40Bits::_gene2weight(1,0,1,1,1), -5000);

    is(Chromosome::40Bits::_gene2weight(1,1,0,0,0), -1);
    is(Chromosome::40Bits::_gene2weight(1,1,0,0,1), -1/5);
    is(Chromosome::40Bits::_gene2weight(1,1,0,1,0), -1/10);
    is(Chromosome::40Bits::_gene2weight(1,1,0,1,1), -1/50);

    is(Chromosome::40Bits::_gene2weight(1,1,1,0,0), -1/100);
    is(Chromosome::40Bits::_gene2weight(1,1,1,0,1), -1/500);
    is(Chromosome::40Bits::_gene2weight(1,1,1,1,0), -1/1000);
    is(Chromosome::40Bits::_gene2weight(1,1,1,1,1), -1/5000);
};

subtest 'weights' => sub {
    my $chromosome = Chromosome::40Bits->new({
        genes => [
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
