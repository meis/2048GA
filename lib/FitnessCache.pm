package FitnessCache;
use v5.10;
use strict;
use Moo;
use Cache::LRU;
use List::MoreUtils qw/natatime/;

use Player;
use Chromosome;
use Parallel::ForkManager;

has games  => (is => 'ro', default => 1);
has forks  => (is => 'ro', default => 4);
has slots  => (is => 'ro', default => 10000);
has _cache => (is => 'lazy');
sub _build__cache  { Cache::LRU->new(size => shift->slots * 2) }
has _fork_manager => (is => 'lazy');
sub _build__fork_manager { Parallel::ForkManager->new(shift->forks) }

sub assign_fitness {
    my ($self, $chromosomes) = @_;

    my @not_in_cache = grep {
        not defined $self->_cache->get($_->key)
    } @$chromosomes;

    $self->_add_to_cache(\@not_in_cache);

    for my $chromosome (@$chromosomes) {
        $chromosome->fitness($self->_cache->get($chromosome->key));
    }
}

sub _add_to_cache {
    my ($self, $chromosomes) = @_;

    my %fitness_per_key;

    $self->_fork_manager->run_on_finish (
        sub {
            my ($pid, $code, $ident, $signal, $dump, $data) = @_;

            if (defined($data)) {
                my $fitnesses = $$data;

                for my $key (keys %$fitnesses) {
                    $fitness_per_key{$key} = $fitnesses->{$key};
                }
            }
        }
    );

    my %uniq_chromosomes = map { $_->key, $_ } @$chromosomes;
    my $iterator = $self->_fork_iterator(values %uniq_chromosomes);

    while (my @batch = $iterator->()) {
        $self->_fork_manager->start and next;

        my $fitnesses = {
            map {
                $_->key => Player->new({ chromosome => $_ })->play($self->games)
            } @batch
        };

        $self->_fork_manager->finish(0, \$fitnesses);
    }

    $self->_fork_manager->wait_all_children;

    for my $key (keys %fitness_per_key) {
        $self->_cache->set($key, $fitness_per_key{$key});
    }
}

sub _fork_iterator {
    my ($self, @items) = @_;

    my $items_per_fork =  $self->forks < 1 ? scalar @items : scalar @items / $self->forks;
    $items_per_fork = 1 if $items_per_fork < 1;

    return natatime $items_per_fork, @items;
}

1;
