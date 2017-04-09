#!/bin/env perl
use v5.10;
use strict;
use Test::More;

use Game2048::State;
use Minion::Brain;
use Minion::Chromosome;

sub test_calc {
    my ($calcs, $method, @expected) = @_;

    subtest "method $method" => sub {
        for my $tile (0..15) {
            is($calcs->{$method}[$tile], $expected[$tile],
                "value of $method for tile $tile");
        }
    };
}

subtest 'evaluate board' => sub {
    my $brain = Minion::Brain->new({
        chromosome => Minion::Chromosome->new({
            weights => {
                position              => 2,
                score                 => 2,
                empty_tiles           => 2,
                tile_value            => 2,
                tile_neighbours       => 2,
                tile_empty_neighbours => 2,
                tile_min_distance     => 2,
                tile_max_distance     => 2,
            },
        }),
    });

    my ($evaluation, $calcs) = $brain->evaluate(
        Game2048::State->new({
            board => [qw/
                0 4 0 0
                0 1 0 1
                0 2 0 2
                1 2 1 2
            /],
            score => 400,
        })
    );

    is($evaluation, 5664 + 800 + 14 );

    subtest 'score' => sub {
        is($calcs->{score}, 800);
    };

    subtest 'empty_tiles' => sub {
        is($calcs->{empty_tiles}, 14);
    };

    test_calc($calcs, 'tile_value', qw/
         0 32  0  0
         0  4  0  4
         0  8  0  8
         4  8  4  8
    /);

    test_calc($calcs, 'tile_neighbours', qw/
         4  6  6  4
         6  8  8  6
         6  8  8  6
         4  6  6  4
    /);

    test_calc($calcs, 'tile_empty_neighbours', qw/
         2  4  4  2
         4  4  4  4
         2  4  2  2
         2  0  2  0
    /);

    test_calc($calcs, 'tile_min_distance', qw/
         0  6  0  0
         0  2  0  2
         0  0  0  0
         2  0  2  0
    /);

    test_calc($calcs, 'tile_max_distance', qw/
         0  6  0  0
         0  6  0  2
         0  2  0  2
         2  2  2  2
    /);

    test_calc($calcs, 'tile_total', qw/
         6 54 10  6
        10 24 12 18
         8 22 10 18
        14 16 16 14
    /);

    subtest 'tiles_by_value' => sub {
        is_deeply($calcs->{tiles_by_value},
            [6, 6, 8, 10, 10, 10, 12, 14, 14, 16, 16, 18, 18, 22, 24, 54]);
    };

    subtest 'tile_evatuations' => sub {
        my $expected_evaluation = [
             6 *  1 * 2,
             6 *  2 * 2,
             8 *  3 * 2,
            10 *  4 * 2,
            10 *  5 * 2,
            10 *  6 * 2,
            12 *  7 * 2,
            14 *  8 * 2,
            14 *  9 * 2,
            16 * 10 * 2,
            16 * 11 * 2,
            18 * 12 * 2,
            18 * 13 * 2,
            22 * 14 * 2,
            24 * 15 * 2,
            54 * 16 * 2,
        ];

        is_deeply($calcs->{tile_evaluations}, $expected_evaluation);
    };

};

done_testing();
