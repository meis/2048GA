package Chromosome;
use v5.10;
use strict;
use warnings;
use Data::Dumper;
use Moo;

has bits    => (is => 'ro', default => 8);
has decimal => (is => 'ro', default => 0);
has genes   => (is => 'lazy');
has weights => (is => 'lazy');

sub key  { join('', @{shift->genes}) }
sub to_string {
    my $self = shift;
    local $Data::Dumper::Terse = 1;
    Dumper($self->weights);
}

sub _build_genes  {[ map {0} 1..(8 * shift->bits) ]}

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
