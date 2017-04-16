package ExperimentParallel;
use v5.10;
use strict;
use Moo;
use Carp qw/cluck/;

use AI::Genetic;
use Minion::Chromosome;

use Data::Dumper;
use Parallel::ForkManager;

has generations => (is => 'ro', default => 100);
has population  => (is => 'ro', default => 50);

our $cache = {};

our $ga;

sub run {
    my $self = shift;

    $ga = new AI::Genetic(
        -fitness    => \&_fitness,
        -type       => 'bitvector',
        -population => $self->population,
        -crossover  => 0.9,
        -mutation   => 0.5,
    );

    $ga->init(40);
    $self->print_current_state($ga);

    for my $n (1..$self->generations) {
        $ga->evolve('rouletteUniform', 1);
        $self->print_current_state($ga);
    }
    say "Best score: " . $ga->people->[0];
    $ga->chart(-filename => 'evolution.png');
}

sub print_current_state {
    my ($self, $ga) = @_;

    say "---------------------------------";
    say "Generation " . $ga->generation();
    say "Best score: " . $ga->getFittest->score;
    say "---------------------------------";
    #    say Dumper($cache);
    say "---------------------------------";
}

sub _fitness {
    my (@chromosomes) = @_;

    #cluck;

    my $ga_chromosomes = $ga->{PEOPLE};
    my $current_key = join('', @{$chromosomes[0]});

    my %not_in_cache;

    for my $chromosome (@{$ga_chromosomes}) {
        my $key = join('', @{$chromosome->{GENES}});

        $not_in_cache{$key} = $chromosome->{GENES} unless $cache->{$key};
    }

    for my $chromosome (@chromosomes) {
        my $key = join('', @$chromosome);
        $not_in_cache{$key} = $chromosome unless $cache->{$key};
    }

    #    say @{$ga_chromosomes} . ' chromosomes in list';
    say(keys(%not_in_cache) . ' chromosomes not in cache') if keys %not_in_cache;


    my $pm = Parallel::ForkManager->new(30);

    $pm->run_on_finish (
        sub {
            my ($pid, $exit_code, $ident, $exit_signal, $core_dump, $data_structure_reference) = @_;

            if (defined($data_structure_reference)) {
              $cache->{${$data_structure_reference}->[0]} += ${$data_structure_reference}->[1];
            }
        }
    );

    for my $key (keys %not_in_cache) {
        $pm->start and next;
        my $fitness = Minion::Chromosome->new({ bits => $not_in_cache{$key} })->build_individual->play(10);
        $pm->finish(0, \[$key, $fitness]);
    }

    $pm->wait_all_children;

    return $cache->{$current_key};

}

BEGIN {
  use AI::Genetic::OpSelection;
  my $old_top_n = \&AI::Genetic::OpSelection::topN;
  *AI::Genetic::OpSelection::topN = sub {
      my $newPop = $_[0];
      $ga->{FITFUNC}->( map { [$_->genes] } @$newPop );
      $old_top_n->(@_);
  }
}

1;
