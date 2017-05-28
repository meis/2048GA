package Chromosome::0Sum;
use v5.10;
use strict;
use warnings;
use Moo::Role;

=head1 NAME

Chromosome::0Sum - Abstract Class for 0 Sum Chromosomes.

=head1 DESCRIPTION

The sum of all weights of a 0 Sum Chromosome must be 0. To ensure that,
each gene can have any weight name as value.

Half of the genes add 1 to it's weight and the other half subtracts 1 from it.

Each implementation must decide the C<size> of the Chromosome.

=cut

with 'Chromosome';

requires '_build_size';

has size => (is => 'lazy');

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

