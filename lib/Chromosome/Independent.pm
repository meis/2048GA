package Chromosome::Independent;
use v5.10;
use strict;
use warnings;
use Moo::Role;

with 'Chromosome';

requires '_build_bits';
requires '_build_decimal';

=head1 NAME

Chromosome::Independent - Abstract Class for value independent Chromosomes.

=head1 DESCRIPTION

A value independent Chromosome uses n bits to encode each weight value.
Optionally, then divides the value to obtain m decimals.

Each implementation must decide the number of C<bits> and C<decimal>.

=cut

has bits    => (is => 'lazy');
has decimal => (is => 'lazy');

sub gene_values { (0, 1) }

sub _build_genes  {
    my $self = shift;

    my $number_of_genes = 8 * $self->bits;

    return [ map { rand() < 0.5 ? 0 : 1 } 1..$number_of_genes ];
}

sub _build_weights {
    my $self = shift;

    my @genes = @{$self->genes};
    return {
        position              => $self->_gene2weight(splice(@genes, 0, $self->bits)),
        score                 => $self->_gene2weight(splice(@genes, 0, $self->bits)),
        empty_tiles           => $self->_gene2weight(splice(@genes, 0, $self->bits)),
        tile_value            => $self->_gene2weight(splice(@genes, 0, $self->bits)),
        tile_neighbours       => $self->_gene2weight(splice(@genes, 0, $self->bits)),
        tile_empty_neighbours => $self->_gene2weight(splice(@genes, 0, $self->bits)),
        tile_min_distance     => $self->_gene2weight(splice(@genes, 0, $self->bits)),
        tile_max_distance     => $self->_gene2weight(splice(@genes, 0, $self->bits)),
    }
}

sub _gene2weight {
    my $self = shift;

    my $sign   = shift @_ ? -1 : 1;
    my @bits   = reverse @_;
    my $multi  = 1;
    my $weight = 0;

    while (@bits) {
        my $bit = shift @bits;
        $weight += $multi if $bit;
        $multi  *= 2;
    }

    $weight *= $sign;

    $weight /= 10 for 1..$self->decimal;

    return $weight;
}

1;
