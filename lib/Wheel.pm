package Wheel;
use v5.10;
use strict;
use warnings;

use List::Util qw/sum/;
use Moo;

has chromosomes    => (is => 'ro', required => 1);
has _probabilities => (is => 'lazy');

sub select {
    my ($self, $number_of_individuals) = @_;

    my @selected;

    for (1..$number_of_individuals) {
        push @selected, $self->_get(rand);
    }

    return @selected;
}

sub _get {
    my ($self, $value) = @_;

    for my $element (@{$self->_probabilities}) {
        return $element->{chromosome} if $value < $element->{probability};
    }

    return $self->_probabilities->[-1]->{chromosome};
}

sub _build__probabilities {
    my $self = shift;

    my @chromosomes = @{$self->chromosomes};
    my $total_fitness = sum map { $_->fitness } @chromosomes;

    my @data;

    my $probability = 0;

    for my $chromosome (@chromosomes) {
        $probability += ($chromosome->fitness / $total_fitness);
        push @data, { probability => $probability, chromosome => $chromosome };
    }

    return \@data;
}

1;
