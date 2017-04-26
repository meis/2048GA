#!/bin/env perl
use v5.10;
use strict;
use Test::More;
use List::Util qw/sum/;

use Board;

subtest 'new board' => sub {
    my $board = Board->new();
    my @tiles = @{$board->tiles};

    my $empty_tiles = grep { $_ eq 0 } @tiles;
    my $total_tiles = sum @tiles;

    is($empty_tiles, 14);
    ok($total_tiles eq 2 or $total_tiles eq 3);
};

subtest 'finished' => sub {
    my $non_finished_board = Board->new({
        tiles => [qw/
            1 1 1 1
            2 1 1 1
            2 2 1 2
            1 2 1 2
        /],
    });

    my $finished_board = Board->new({
        tiles => [qw/
            2 1 2 1
            1 2 1 2
            2 1 2 1
            1 2 1 2
        /],
    });

    ok(!$non_finished_board->finished());
    ok($finished_board->finished());
};

subtest 'move' => sub {
    my $board = Board->new({
        tiles => [qw/
            0 0 0 0
            2 0 3 0
            2 0 3 0
            1 0 0 0
        /],
    });

    my $expected_tiles = [qw/
        0 0 0 0
        0 0 0 0
        3 0 0 0
        1 0 4 0
    /];

    $board = $board->move('down');

    my $empty_tiles = grep { $_ eq 0 } @{$board->tiles};
    my $total_tiles = sum @{$board->tiles};

    is($empty_tiles, 12);
    ok($total_tiles eq 9 or $total_tiles eq 10);
};

subtest 'next moves' => sub {
    my @cases = (
        {
            tiles => [qw/
                0 0 0 0
                0 1 0 1
                0 2 0 2
                1 2 1 2
            /],
            score => 0,
            moves => {
                left => {
                    tiles => [qw/
                        0 0 0 0
                        2 0 0 0
                        3 0 0 0
                        1 2 1 2
                    /],
                    score => 12,
                },
                right => {
                    tiles => [qw/
                        0 0 0 0
                        0 0 0 2
                        0 0 0 3
                        1 2 1 2
                    /],
                    score => 12,
                },
                up => {
                    tiles => [qw/
                        1 1 1 1
                        0 3 0 3
                        0 0 0 0
                        0 0 0 0
                    /],
                    score => 16,
                },
                down => {
                    tiles => [qw/
                        0 0 0 0
                        0 0 0 0
                        0 1 0 1
                        1 3 1 3
                    /],
                    score => 16,
                },
            },
        },
        {
            tiles => [qw/
                3 2 1 2
                3 0 0 0
                3 0 0 0
                3 0 0 0
            /],
            score => 2000,
            moves => {
                right => {
                    tiles => [qw/
                        3 2 1 2
                        0 0 0 3
                        0 0 0 3
                        0 0 0 3
                    /],
                    score => 2000,
                },
                up => {
                    tiles => [qw/
                        4 2 1 2
                        4 0 0 0
                        0 0 0 0
                        0 0 0 0
                    /],
                    score => 2032,
                },
                down => {
                    tiles => [qw/
                        0 0 0 0
                        0 0 0 0
                        4 0 0 0
                        4 2 1 2
                    /],
                    score => 2032,
                },
            },
        },
    );

    my $n = 0;
    for my $case (@cases) {
        $n++;

        subtest "board $n" => sub {
            my $state;
            my $args = {
                tiles => $case->{tiles},
                score => $case->{score},
            };

            ok($state = Board->new($args));

            my @available_moves = keys %{$case->{moves}};
            is($state->available_moves, @available_moves);

            for my $direction (@available_moves) {
                subtest "moving $direction" => sub {
                    my $move = $state->moves->{$direction};
                    my $expected = $case->{moves}{$direction};
                    is_deeply($move->tiles, $expected->{tiles});
                    is($move->score, $expected->{score});
                };
            }
        };
    }
};

done_testing();
