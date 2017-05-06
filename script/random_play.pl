#!/usr/bin/env perl
use v5.10;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Board;
use List::Util qw/shuffle/;

my $number_of_plays = shift || 1;
play($number_of_plays);

sub play {
    my $self = shift;
    my $times = shift || 1;
    my $total_score = 0;

    say "Playing $number_of_plays random games";

    for (0..$number_of_plays -1) {
        my $board = Board->new;

        while (!$board->finished) {
            my @moves = shuffle $board->available_moves;
            $board = $board->move(shift @moves);
        }

        $total_score += $board->score;
    }

    say "Average score: " . $total_score / $number_of_plays;
}

