package Experiment;
use v5.10;
use strict;
use Moo;

use AI::Genetic::Pro::Parallel;
use Minion::Chromosome;

has generations => (is => 'ro', default => 100);
has population  => (is => 'ro', default => 50);

sub run {
    my $self = shift;

    my $ga = AI::Genetic::Pro::Parallel->new(
        -fitness         => \&_fitness,        # fitness function
        -type            => 'bitvector',      # type of chromosomes
        -population      => $self->population,             # population
        -crossover       => 0.9,              # probab. of crossover
        -mutation        => 0.1,             # probab. of mutation
        -parents         => 2,                # number  of parents
        -selection       => [ 'Roulette' ],   # selection strategy
        -strategy        => [ 'Points', 3 ],  # crossover strategy
        -cache           => 1,                # cache results
        -history         => 1,                # remember best results
        -preserve        => 3,                # remember the bests
    );

    $ga->init(40);
    $self->print_current_state($ga);

    for my $n (0..$self->generations -1 ) {
        $ga->evolve(1);
        $self->print_current_state($ga);
    }
    say "Best score: " . $ga->as_string($ga->chromosomes->[0]);

    # save evolution path as a chart
    $ga->chart(-filename => 'evolution.png');
}

sub print_current_state {
    my ($self, $ga) = @_;

    say "---------------------------------";
    say "Generation " . $ga->generation();
    say "Best score: " . $ga->as_value($ga->getFittest);
    say "---------------------------------";
}

sub _fitness {
    my ($ga, $bits) = @_;

    Minion::Chromosome->new({ bits => $bits })->build_individual->play(100);
}

1;
