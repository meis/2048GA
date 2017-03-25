#!/bin/env perl
use v5.10;
use strict;
use Test::More;
use Game2048::State;

subtest 'next moves' => sub {
    my @cases = (
        {
            board => [qw/
                0 0 0 0
                0 1 0 1
                0 2 0 2
                1 2 1 2
            /],
            score => 0,
            moves => {
                left => {
                    board => [qw/
                        0 0 0 0
                        2 0 0 0
                        3 0 0 0
                        1 2 1 2
                    /],
                    score => 12,
                },
                right => {
                    board => [qw/
                        0 0 0 0
                        0 0 0 2
                        0 0 0 3
                        1 2 1 2
                    /],
                    score => 12,
                },
                up => {
                    board => [qw/
                        1 1 1 1
                        0 3 0 3
                        0 0 0 0
                        0 0 0 0
                    /],
                    score => 16,
                },
                down => {
                    board => [qw/
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
            board => [qw/
                3 2 1 2
                3 0 0 0
                3 0 0 0
                3 0 0 0
            /],
            score => 2000,
            moves => {
                right => {
                    board => [qw/
                        3 2 1 2
                        0 0 0 3
                        0 0 0 3
                        0 0 0 3
                    /],
                    score => 2000,
                },
                up => {
                    board => [qw/
                        4 2 1 2
                        4 0 0 0
                        0 0 0 0
                        0 0 0 0
                    /],
                    score => 2032,
                },
                down => {
                    board => [qw/
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
                board => $case->{board},
                score => $case->{score},
            };

            ok($state = Game2048::State->new($args));

            my @available_moves = keys %{$case->{moves}};
            is($state->available_moves, @available_moves);

            for my $direction (@available_moves) {
                subtest "moving $direction" => sub {
                    my $move = $state->moves->{$direction};
                    my $expected = $case->{moves}{$direction};
                    is_deeply($move->board, $expected->{board});
                    is($move->score, $expected->{score});
                };
            }
        };
    }
};

done_testing();
