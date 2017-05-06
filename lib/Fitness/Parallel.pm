package Fitness::Parallel;
use v5.10;
use strict;
use Moo;
use Cache::LRU;
use List::MoreUtils qw/natatime/;

use Player;
use Chromosome;
use Parallel::ForkManager;

has play       => (is => 'ro', default => 1);
has bits       => (is => 'ro', default => 8);
has decimal    => (is => 'ro', default => 0);
has population => (is => 'ro', default => 1000);

has cache      => (is => 'lazy');
sub _build_cache  { Cache::LRU->new(size => shift->population * 2) }

sub run {
    my ($self, $ga, $genes) = @_;

    # Ensure all individuals of current generation are already in the cache.
    # This allows to fill the cache only once and run all fitness functions
    # in parallel.
    $self->_fill_cache($ga->people);

    my $key = join('', @{$genes});

    return $self->cache->get($key);
}

sub _fill_cache {
    my ($self, $individuals) = @_;

    my %not_in_cache;

    for my $individual (@$individuals) {
        my $chromosome = Chromosome->new({
            genes   => [$individual->genes],
            bits    => $self->bits,
            decimal => $self->decimal,
        });

        $not_in_cache{$chromosome->key} = $chromosome
          unless $self->cache->get($chromosome->key);
    }

    return unless keys %not_in_cache;

    $self->_fill_in_parallel(%not_in_cache);
}

sub _fill_in_parallel {
    my ($self, %chromosomes) = @_;

    my $pm = Parallel::ForkManager->new(scalar keys %chromosomes);

    $pm->run_on_finish (
        sub {
            my ($pid, $code, $ident, $signal, $dump, $data) = @_;

            if (defined($data)) {
                my $fitnesses = $$data;

                for my $key (keys %$fitnesses) {
                    $self->cache->set($key, $fitnesses->{$key});
                }
            }
        }
    );

    my $iterator = natatime 10, keys %chromosomes;

    # Start a new fork for every 10 items to add to cache
    while (my @keys = $iterator->()) {
        $pm->start and next;

        my $fitnesses = {
            map {
                $_ => $self->_player_fitness($chromosomes{$_})
            } @keys
        };

        $pm->finish(0, \$fitnesses);
    }

    $pm->wait_all_children;
}

sub _player_fitness {
    my ($self, $chromosome) = @_;

    my $player = Player->new({ chromosome => $chromosome });

    return $player->play($self->play);
}

1;
