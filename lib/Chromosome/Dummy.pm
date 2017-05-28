package Chromosome::Dummy;
use v5.10;
use strict;
use warnings;
use Moo;

with 'Chromosome';

sub gene_values { 0, 1 }
sub _build_genes { [0, 0] }

sub _build_weights {
    return {
        position              => rand(),
        score                 => rand(),
        empty_tiles           => rand(),
        tile_value            => rand(),
        tile_neighbours       => rand(),
        tile_empty_neighbours => rand(),
        tile_min_distance     => rand(),
        tile_max_distance     => rand(),
    }
}

1;
