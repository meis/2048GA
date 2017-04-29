package Experiment;
use v5.10;
use strict;
use Data::Dumper;
use Moo;
use Module::Load;
use AI::Genetic;

has generations      => (is => 'ro', default => 100);
has population       => (is => 'ro', default => 50);
has play             => (is => 'ro', default => 10);
has mutation         => (is => 'ro', default => 0.05);
has crossover        => (is => 'ro', default => 0.9);
has strategy         => (is => 'ro', default => 'rouletteTwoPoint');
has chromosome_class => (is => 'ro', default => 'Chromosome::40Bits');
has fitness_class    => (is => 'ro', default => 'Fitness::Base');
has fitness_function => (is => 'lazy');
has ga               => (is => 'lazy');

sub run {
    my $self = shift;

    load($self->fitness_class);
    load($self->chromosome_class);

    $self->ga->init($self->chromosome_class->init);
    $self->print_current_state();

    for my $n (0..$self->generations -1 ) {
        $self->ga->evolve($self->strategy, 1);
        $self->print_current_state();
    }
    my $best_chromosome = $self->chromosome_class->new({
        genes => [$self->ga->people->[0]->genes],
    });
    say 'Weights of best chromosome:';
    say Dumper($best_chromosome->to_string);

}

sub print_current_state {
    my $self = shift;

    say "---------------------------------";
    say "Generation " . $self->ga->generation();
    say "Best score: " . $self->ga->getFittest->score;
    say "---------------------------------";
}

sub _build_ga {
    my $self = shift;

    return AI::Genetic->new(
        -fitness         => $self->fitness_function,
        -type            => $self->chromosome_class->type,
        -population      => $self->population,
        -crossover       => $self->crossover,
        -mutation        => $self->mutation,
    );
}

sub _build_fitness_function {
    my $self = shift;

    my $fitness = $self->fitness_class->new({
        play => $self->play,
        chromosome_class => $self->chromosome_class,
    });

    return sub { $fitness->run($self->ga, @_) };
}

1;
