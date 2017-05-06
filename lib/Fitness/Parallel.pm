package Fitness::Parallel;
use v5.10;
use strict;
use Moo;
use Player;
use Chromosome;
use Parallel::ForkManager;

has play    => (is => 'ro', default => 1);
has bits    => (is => 'ro', default => 8);
has decimal => (is => 'ro', default => 0);
has cache   => (is => 'ro', default => sub { {} });

sub run {
    my ($self, $ga, $genes) = @_;

    # Ensure all individuals of current generation are already in the cache.
    # This allows to fill the cache only once and run all fitness functions
    # in parallel.
    $self->_patch_op_selection();

    $self->_fill_cache($ga->people);

    my $key = join('', @{$genes});

    return $self->cache->{$key};
}

#
# The fitness function is called on individuals on AI::Genetic::OpSelction
# topN in a map to sort individuals for fitness value.
# Here, we are wrapping this function to pre-cache all the individuals to be
# sorted before the actual fitness function is called. Then, all calls inside
# topN will only be cache accesses.
#
sub _patch_op_selection {
    my $self = shift;

    unless ($AI::Genetic::OpSelection::__topN_redefined) {
        no warnings 'redefine';
        use AI::Genetic::OpSelection;

        my $old_top_n = \&AI::Genetic::OpSelection::topN;

        *AI::Genetic::OpSelection::topN = sub {
          $self->_fill_cache($_[0]);
          $old_top_n->(@_);
        };

        $AI::Genetic::OpSelection::__topN_redefined = 1;
    }
}

sub _fill_cache {
    my ($self, $individuals) = @_;

    my %not_in_cache;

    for my $individual (@$individuals) {
        my $chromosome = Chromosome->new({
            genes => [$individual->genes],
            bits    => $self->bits,
            decimal => $self->decimal,
        });

        $not_in_cache{$chromosome->key} = $chromosome
          unless $self->cache->{$chromosome->key};
    }

    $self->_fill_in_parallel(%not_in_cache);
}

sub _fill_in_parallel {
    my ($self, %chromosomes) = @_;

    my $pm = Parallel::ForkManager->new(scalar keys %chromosomes);

    $pm->run_on_finish (
        sub {
            my ($pid, $code, $ident, $signal, $dump, $data) = @_;

            if (defined($data)) {
              $self->cache->{${$data}->[0]} += ${$data}->[1];
            }
        }
    );

    for my $key (keys %chromosomes) {
        $pm->start and next;

        my $chromosome = $chromosomes{$key};

        $pm->finish(0, \[$key, $self->_player_fitness($chromosome)]);
    }

    $pm->wait_all_children;
}

sub _player_fitness {
    my ($self, $chromosome) = @_;

    my $player = Player->new({ chromosome => $chromosome });

    return $player->play($self->play);
}

1;
