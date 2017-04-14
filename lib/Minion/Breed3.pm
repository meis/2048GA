package Minion::Breed3;
use v5.10;
use strict;
use AI::Genetic::Pro;
use Minion::Chromosome;

use constant GENERATIONS => 100;
use constant POPULATION => 50;
use constant WEIGHTS => 8;
use constant BITS_PER_WEIGHT => 5;

sub start {
    my $ga = AI::Genetic::Pro->new(
        -fitness         => \&_fitness,        # fitness function
        -type            => 'bitvector',      # type of chromosomes
        -population      => +POPULATION,             # population
        -crossover       => 0.9,              # probab. of crossover
        -mutation        => 0.05,             # probab. of mutation
        -parents         => 2,                # number  of parents
        -selection       => [ 'Roulette' ],   # selection strategy
        -strategy        => [ 'Points', 2 ],  # crossover strategy
        -cache           => 0,                # cache results
        -history         => 1,                # remember best results
        -preserve        => 3,                # remember the bests
        #        -variable_length => 1,                # turn variable length ON
    );

    # init population of 32-bit vectors
    $ga->init(+WEIGHTS * +BITS_PER_WEIGHT);
    say "Generation " . $ga->generation();
    say "Best score: " . $ga->as_value($ga->getFittest);
    say "---------------------------------";

# 15 generations
    for my $n (0..+GENERATIONS) {
        $ga->evolve(1);
        say "Generation " . $ga->generation();
        say "Best score: " . $ga->as_value($ga->getFittest);
        say "---------------------------------";
    }
    say "Best score: " . $ga->as_value($ga->getFittest);

    # save evolution path as a chart
    $ga->chart(-filename => 'evolution.png');
}

sub _fitness {
    my ($ga, $chromosome) = @_;

    Minion::Chromosome->new($chromosome)->get_individual->play(100);
}

1;
