package Experiment;
use v5.10;
use strict;
use Data::Dumper;
use Moo;
use Module::Load;
use AI::Genetic;

has generations      => (is => 'ro', default => 100);
has population       => (is => 'ro', default => 50);
has play             => (is => 'ro', default => 20);
has mutation         => (is => 'ro', default => 0.05);
has crossover        => (is => 'ro', default => 0.9);
has strategy         => (is => 'ro', default => 'rouletteUniform');
has bits             => (is => 'ro', default => 8);
has decimal          => (is => 'ro', default => 0);
has fitness_class    => (is => 'ro', default => 'Base');
has fitness_function => (is => 'lazy');
has ga               => (is => 'lazy');
has weights          => (is => 'lazy');

around fitness_class    => sub { my $o = shift; 'Fitness::' . $o->(shift, @_) };

sub run {
    my $self = shift;

    load($self->fitness_class);

    $self->_print_headers();
    $self->ga->init(8 * $self->bits);
    $self->_print_generation();

    for my $n (0..$self->generations -1 ) {
        $self->ga->evolve($self->strategy, 1);
        $self->_print_generation();
    }
}

sub _print_headers {
    my $self = shift;

    say join(',', 'Generation', 'Fitness', @{$self->weights});
}

sub _print_generation {
    my $self = shift;

    for my $individual (@{$self->ga->people}) {
        my $chromosome = Chromosome->new({
            genes   => [$individual->genes],
            bits    => $self->bits,
            decimal => $self->decimal,
        });

        my @weight_values = map { $chromosome->weights->{$_} } @{$self->weights};

        say join(',', $self->ga->generation, $individual->score, @weight_values);
    }
}

sub _build_weights {
    my $self = shift;

    return [sort keys %{ Chromosome->new()->weights }];
}

sub _build_ga {
    my $self = shift;

    return AI::Genetic->new(
        -fitness         => $self->fitness_function,
        -type            => 'bitvector',
        -population      => $self->population,
        -crossover       => $self->crossover,
        -mutation        => $self->mutation,
    );
}

sub _build_fitness_function {
    my $self = shift;

    my $fitness = $self->fitness_class->new({
        play => $self->play,
        bits => $self->bits,
        decimal => $self->decimal,
    });

    return sub { $fitness->run($self->ga, @_) };
}

1;
