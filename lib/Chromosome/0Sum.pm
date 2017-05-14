package Chromosome::0Sum;
use v5.10;
use strict;
use warnings;
use Moo::Role;

with 'Chromosome';

requires '_build_size';

has size=> (is => 'lazy');

sub gene_values { shift->weight_keys() }

sub _build_genes {
    my $self = shift;

    my @possible_values = $self->weight_keys();
    my @genes;

    for ( 1 .. $self->size ) {
        push @genes, $possible_values[ rand @possible_values ];
    }

    return \@genes;
}

sub _build_weights {
    my $self = shift;

    my %weights = map { $_ => 0 } $self->weight_keys;

    for my $i (0 .. $self->size - 1) {
        my $weight = $self->genes->[$i];
        $weights{$weight} += $i % 2 == 0 ? 1 : -1;
    }

    return \%weights;
}

1;

