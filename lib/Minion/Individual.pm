package Minion::Individual;
use v5.10;
use strict;
use Moo;
use Game2048::Engine;
use Minion::Brain;
use Minion::Chromosome;

has chromosome => (is => 'ro', default => sub { Minion::Chromosome->new } );
has brain       => (is => 'lazy');

sub _build_brain { Minion::Brain->new({ chromosome => shift->chromosome }) }

sub play {
    my $self = shift;
    my $times = shift || 1;
    my $total_score = 0;

    for (0..$times -1) {
        my $game = Game2048::Engine->new;

        while (!$game->finished) {
            $game->move($self->brain->decide($game->state));
        }

        $total_score += $game->state->score;
    }

    return $total_score / $times;
}

1;
