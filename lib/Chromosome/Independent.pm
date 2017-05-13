package Chromosome::Independent;
use v5.10;
use strict;
use warnings;
use Moo;

with 'Chromosome';

has bits    => (is => 'ro', default => 8);
has decimal => (is => 'ro', default => 0);
has genes   => (is => 'lazy');

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

sub crossover {
    my ($self, $mate) = @_;

    my (@son_genes, @dau_genes);

    for my $i (0 .. @{$self->genes} - 1) {
        if (rand > 0.5) {
            push @son_genes, $self->genes->[$i];
            push @dau_genes, $mate->genes->[$i];
        } else {
            push @son_genes, $mate->genes->[$i];
            push @dau_genes, $self->genes->[$i];
        }
    }

    return (
        __PACKAGE__->new({ genes => \@son_genes }),
        __PACKAGE__->new({ genes => \@dau_genes }),
    );
}

sub mutate {
    my $self = shift;

    my $index = int(rand(@{$self->genes}));

    $self->genes->[$index] = !! $self->genes->[$index];
}

1;

