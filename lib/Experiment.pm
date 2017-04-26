package Experiment;
use v5.10;
use strict;
use Moo;

use AI::Genetic::Pro;

has generations => (is => 'ro', default => 100);
has population  => (is => 'ro', default => 50);
has play        => (is => 'ro', default => 10);
has fitness_class    => (is => 'ro', default => 'Fitness::Base');
has chromosome_class => (is => 'ro', default => 'Chromosome::40Bits');
has fitness_function => (is => 'lazy');

sub run {
    my $self = shift;

    eval("use " . $self->fitness_class);
    eval("use " . $self->chromosome_class);

    my $ga = AI::Genetic::Pro->new(
        -fitness         => $self->fitness_function,        # fitness function
        -type            => $self->chromosome_class->type,      # type of chromosomes
        -population      => $self->population,             # population
        -crossover       => 0.9,              # probab. of crossover
        -mutation        => 0.05,             # probab. of mutation
        -parents         => 2,                # number  of parents
        -selection       => [ 'Roulette' ],   # selection strategy
        -strategy        => [ 'Points', 2 ],  # crossover strategy
        -cache           => 1,                # cache results
        -history         => 1,                # remember best results
        -preserve        => 3,                # remember the bests
    );

    $ga->init($self->chromosome_class->init);
    $self->print_current_state($ga);

    for my $n (0..$self->generations -1 ) {
        $ga->evolve(1);
        $self->print_current_state($ga);
    }
    say "Best score: " . $ga->as_string($ga->chromosomes->[0]);
}

sub print_current_state {
    my ($self, $ga) = @_;

    say "---------------------------------";
    say "Generation " . $ga->generation();
    say "Best score: " . $ga->as_value($ga->getFittest);
    say "---------------------------------";
}

sub _build_fitness_function {
    my $self = shift;

    my $fitness = $self->fitness_class->new({
        play => $self->play,
        chromosome_class => $self->chromosome_class,
    });

    return sub { $fitness->run(@_) };
}

1;
