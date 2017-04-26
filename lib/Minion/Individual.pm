package Minion::Individual;
use v5.10;
use strict;
use Moo;
use Game2048::Board;
use Minion::Brain;
use Chromosome;

has chromosome => (is => 'ro', default => sub { Chromosome->new } );
has brain       => (is => 'lazy');

sub _build_brain { Minion::Brain->new({ chromosome => shift->chromosome }) }

sub play {
    my $self = shift;
    my $times = shift || 1;
    my $total_score = 0;

    for (0..$times -1) {
        my $board = Game2048::Board->new;

        while (!$board->finished) {
            $board = $board->move($self->brain->decide($board));
        }

        $total_score += $board->score;
    }

    return $total_score / $times;
}

1;
