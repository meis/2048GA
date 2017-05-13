#!/bin/env perl
use v5.10;
use strict;
use Test::More;

use Board;
use Player;
use Chromosome::Dummy;

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
    my $player = Player->new({
        chromosome => Chromosome::Dummy->new({
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

    my ($evaluation, $calcs) = $player->evaluate(
        Board->new({
            tiles => [qw/
                0 4 0 0
                0 1 0 1
                0 2 0 2
                1 2 1 2
            /],
            score => 400,
        })
    );

    is($evaluation, 905.6 + 800 + 14 );

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
         8  8  8  2
         2  6  2  2
         4  4  4  4
         2  2  2  2
    /);

    test_calc($calcs, 'tile_total', qw/
        14 56 18  8
        12 24 14 18
        12 24 14 20
        14 16 16 14
    /);

    subtest 'tiles_by_value' => sub {
        is_deeply($calcs->{tiles_by_value},
            [8, 12, 12, 14, 14, 14, 14, 14, 16, 16, 18, 18, 20, 24, 24, 56]);
    };

    subtest 'tile_evatuations' => sub {
        my $expected_evaluation = [
             8 * 1.2,
            12 * 1.4,
            12 * 1.6,
            14 * 1.8,
            14 * 2,
            14 * 2.2,
            14 * 2.4,
            14 * 2.6,
            16 * 2.8,
            16 * 3,
            18 * 3.2,
            18 * 3.4,
            20 * 3.6,
            24 * 3.8,
            24 * 4,
            56 * 4.2,
        ];

        is_deeply($calcs->{tile_evaluations}, $expected_evaluation);
    };

};

done_testing();
