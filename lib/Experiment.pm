package Experiment;
use v5.10;
use autodie;
use strict;
use warnings;

use FitnessAssigner;
use List::MoreUtils qw/natatime/;
use Module::Load;
use Moo;
use Wheel;

=head1 NAME

Experiment - Genetic algorithm to optimize Chromosome.

=head1 SYNOPSIS

    use Experiment;

    my $experiment = Experiment->new({ generations => 42 });
    $experiment->run;

=head1 DESCRIPTION

This module provides the main interface to run experiments. An experiment is an
envolution of a finite number of C<generations>.

The method C<run> saves the generation, fitnees and weights of every chromosome
used in a file, or prints it if C<stdout> is truthy.

=cut

has generations => (is => 'ro', default => 100);
has population  => (is => 'ro', default => 50);
has games       => (is => 'ro', default => 20);
has mutation    => (is => 'ro', default => 0.05);
has crossover   => (is => 'ro', default => 0.9);

has forks       => (is => 'ro', default => 4);
has chromosome  => (is => 'ro', default => 'Chromosome::Independent::8bit');

has stdout      => (is => 'ro', default => 0);
has _file_name  => (is => 'lazy');
has _fh         => (is => 'lazy');

has _fitness_assigner => (is => 'lazy');

sub run {
    my $self = shift;

    say('Output: ' . $self->_file_name) if $self->_file_name;

    load($self->chromosome);

    $self->_print_headers;
    my $generation = $self->_initial_generation();
    $self->_print_generation(0, $generation);

    for my $n (1..$self->generations) {
        $generation = $self->_evolve($generation);
        $self->_print_generation($n, $generation);
    }
}

sub _initial_generation {
    my $self = shift;

    my $generation = [ map { $self->chromosome->new } 1..$self->population ];

    $self->_fitness_assigner->assign_fitness($generation);

    return $generation;
}

sub _evolve {
    my ($self, $generation) = @_;

    my $candidates = $self->_generate_candidates($generation);

    my @next_generation = sort {
        $b->fitness <=> $a->fitness
    } (@$generation, @$candidates);

    @next_generation = splice(@next_generation, 0, $self->population);

    return \@next_generation;
}

sub _generate_candidates {
    my ($self, $generation) = @_;

    my $crossover_probability = $self->crossover;
    my $mutation_probability  = $self->mutation;

    my @candidates;

    my $wheel = Wheel->new({ chromosomes => $generation });

    for (1..$self->population / 2) {
        my ($mom, $dad) = $wheel->select(2);

        my ($son, $dau);

        if (rand() < $crossover_probability) {
            ($son, $dau) = $mom->crossover($dad);

            $son->mutate() if (rand() < $mutation_probability);
            $dau->mutate() if (rand() < $mutation_probability);
        }
        else {
            ($son, $dau) = ($self->chromosome->new(), $self->chromosome->new());
        }

        push @candidates, $son, $dau;
    }

    $self->_fitness_assigner->assign_fitness(\@candidates);

    return \@candidates;
}

sub _print_headers {
    my $self = shift;

    $self->_print(join(',', 'Generation', 'Fitness', $self->chromosome->weight_keys));
}

sub _print_generation {
    my ($self, $n, $generation) = @_;

    my @sorted_chromosomes = sort {
        $b->fitness <=> $a->fitness
    } @$generation;

    for my $chromosome (@sorted_chromosomes) {
        my @weight_values = map { $chromosome->weights->{$_} } $self->chromosome->weight_keys;

        $self->_print(join(',', $n, $chromosome->fitness, @weight_values));
    }
}

sub _print {
    my ($self, $message) = @_;

    if (my $fh = $self->_fh) {
        say $fh $message;
    }
    else {
        say $message;
    }
}

sub _build__file_name {
    my $self = shift;

    return undef if $self->stdout;

    my $attributes = join('_', map {
        $_ . '=' . $self->$_
    } qw/chromosome generations population games crossover mutation/);

    return 'output/experiment_'
           . $attributes
           . '_' . time()
           . '.csv';

}

sub _build__fh {
    my $self = shift;

    return undef unless $self->_file_name;

    open(my $fh, ">", $self->_file_name);

    return $fh;
}

sub _build__fitness_assigner {
    my $self = shift;

    return FitnessAssigner->new({
        games => $self->games,
        forks => $self->forks,
        slots => $self->population,
    });
}

1;
