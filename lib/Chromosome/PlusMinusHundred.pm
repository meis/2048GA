package Chromosome::PlusMinusHundred;
use v5.10;
use strict;
use warnings;

use Moo;
with 'Chromosome';

sub init { [ map {[-100, 100]} 0..7 ] }
sub type { 'rangevector' }
sub key  { join(',', @{shift->genes}) }

sub _build_genes  {[ map { 1 } 0..7 ]}

sub _build_weights {
    my $self = shift;

    return {
        position              => $self->genes->[0],
        score                 => $self->genes->[1],
        empty_tiles           => $self->genes->[2],
        tile_value            => $self->genes->[3],
        tile_neighbours       => $self->genes->[4],
        tile_empty_neighbours => $self->genes->[5],
        tile_min_distance     => $self->genes->[6],
        tile_max_distance     => $self->genes->[7],
    }
}

1;
