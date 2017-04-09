package Minion::Chromosome;
use v5.10;
use strict;
use Moo;

use Minion::Individual;

has bits    => (is => 'ro', default => sub {[ map {0} 0..39 ]});
has weights => (is => 'lazy');

sub _build_weights {
    my $self = shift;

    return {
        position              => bits2weight(@{$self->bits}[ 0..4]),
        score                 => bits2weight(@{$self->bits}[ 5..9]),
        empty_tiles           => bits2weight(@{$self->bits}[10..14]),
        tile_value            => bits2weight(@{$self->bits}[15..19]),
        tile_neighbours       => bits2weight(@{$self->bits}[20..24]),
        tile_empty_neighbours => bits2weight(@{$self->bits}[25..29]),
        tile_min_distance     => bits2weight(@{$self->bits}[30..34]),
        tile_max_distance     => bits2weight(@{$self->bits}[35..39]),
    }
}

sub build_individual { Minion::Individual->new({ chromosome => shift }) }

sub bits2weight {
    my $weight = $_[0] ? -1 : 1;

    $weight *= 100 if $_[2];
    $weight *= 10 if $_[3];

    $weight *= 5 if $_[4];

    $weight = $_[1] ? 1 / $weight : $weight;

    return $weight;
}

1;
