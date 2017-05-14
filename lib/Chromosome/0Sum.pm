package Chromosome::0Sum;
use v5.10;
use strict;
use warnings;
use Moo::Role;

with 'Chromosome';

requires '_build_size';

has genes => (is => 'lazy');
has size  => (is => 'lazy');

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

    my @possible_values = $self->weight_keys();
    my $value = $possible_values[ rand @possible_values ];
    my $index = int(rand(@{$self->genes}));

    $self->genes->[$index] = $value;
}

1;

