package Chromosome::40Bits;
use v5.10;
use strict;
use Moo;
with 'Chromosome';

sub init { 40 }
sub type { 'bitvector' }
sub key  { join('', @{shift->genes}) }

sub _build_genes  {[ map {0} 0..39 ]}

sub _build_weights {
    my $self = shift;

    return {
        position              => _gene2weight(@{$self->genes}[ 0..4]),
        score                 => _gene2weight(@{$self->genes}[ 5..9]),
        empty_tiles           => _gene2weight(@{$self->genes}[10..14]),
        tile_value            => _gene2weight(@{$self->genes}[15..19]),
        tile_neighbours       => _gene2weight(@{$self->genes}[20..24]),
        tile_empty_neighbours => _gene2weight(@{$self->genes}[25..29]),
        tile_min_distance     => _gene2weight(@{$self->genes}[30..34]),
        tile_max_distance     => _gene2weight(@{$self->genes}[35..39]),
    }
}

sub _gene2weight {
    my $weight = $_[0] ? -1 : 1;

    $weight *= 100 if $_[2];
    $weight *= 10 if $_[3];

    $weight *= 5 if $_[4];

    $weight = $_[1] ? 1 / $weight : $weight;

    return $weight;
}

1;
