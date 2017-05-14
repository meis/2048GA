package Chromosome;
use v5.10;
use strict;
use warnings;
use Data::Dumper;
use Moo::Role;

requires 'gene_values';
requires '_build_weights';
requires '_build_genes';

has weights => (is => 'lazy');
has genes   => (is => 'lazy');
has key     => (is => 'lazy');
has fitness => (is => 'rw', default => undef);

sub weight_keys {
    return qw(
        position
        score
        empty_tiles
        tile_value
        tile_neighbours
        tile_empty_neighbours
        tile_min_distance
        tile_max_distance
    );
}

sub _build_key {
    my $self = shift;

    return join(',', map { $self->weights->{$_} } $self->weight_keys);
};

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
        $self->new({ genes => \@son_genes }),
        $self->new({ genes => \@dau_genes }),
    );
}

sub mutate {
    my $self = shift;

    my @possible_values = $self->gene_values();
    my $index = int(rand(@{$self->genes}));

    my $old_value = $self->genes->[$index];
    my $new_value = $old_value;

    while ($new_value eq $old_value) {
        $new_value = $possible_values[ rand @possible_values ];
    }

    $self->genes->[$index] = $new_value;
}

sub to_string {
    my $self = shift;

    local $Data::Dumper::Terse = 1;
    Dumper($self->weights);
}

1;
