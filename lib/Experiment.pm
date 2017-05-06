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
has strategy         => (is => 'ro', default => 'custom_strategy');
has bits             => (is => 'ro', default => 8);
has decimal          => (is => 'ro', default => 0);
has fitness_class    => (is => 'ro', default => 'Fitness::Parallel');
has fitness_function => (is => 'lazy');
has ga               => (is => 'lazy');
has weights          => (is => 'lazy');

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

    my $ga = AI::Genetic->new(
        -fitness         => $self->fitness_function,
        -type            => 'bitvector',
        -population      => $self->population,
        -crossover       => $self->crossover,
        -mutation        => $self->mutation,
    );

    $ga->createStrategy('custom_strategy', \&custom_strategy);

    return $ga;
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

sub custom_strategy {
    my $ga = shift;

    my $fitness_function = $ga->people->[0]->fitness;
    my $number_of_genes  = scalar @{$ga->people->[0]->genes};
    my $crossover_probability = $ga->crossProb;
    my $mutation_probability  = $ga->mutProb;

    my $selection = \&{"AI::Genetic::OpSelection::roulette"};
    my $crossover = \&{"AI::Genetic::OpCrossover::vectorUniform"};
    my $mutation  = \&{"AI::Genetic::OpMutation::bitVector"};

    # Initialize the roulette wheel
    AI::Genetic::OpSelection::initWheel($ga->people);

    for my $i (1 .. $ga->size/2) {
        my @parents_genes = map { scalar $_->genes } $selection->();
        my @childs_genes  = $crossover->($crossover_probability, @parents_genes);

        # Check if parents did mate.
        if (ref $childs_genes[0]) {
            @childs_genes = map { $mutation->($mutation_probability, $_) } @childs_genes;
        }
        else {
            # Random genes
            @childs_genes = map {
                [ map { rand > 0.5 ? 1 : 0 } 1 .. $number_of_genes ]
            } 0..1;
        }

        # Add new chromosomes to population
        push @{$ga->people}, map {
            my $individual = AI::Genetic::IndBitVector->newSpecific($_);
            # assign the fitness function. This is UGLY.
            $individual->fitness($fitness_function);
            $individual;
        } @childs_genes;
    }

    # Get only the half fittest individuals
    $ga->people(AI::Genetic::OpSelection::topN($ga->people, $ga->size));
}

1;
