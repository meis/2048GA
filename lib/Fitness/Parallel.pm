package Fitness::Parallel;
use v5.10;
use strict;
use Moo;
use Player;
use Parallel::ForkManager;

use Data::Dumper;

has chromosome_class => (is => 'ro', requrired => 1);
has play             => (is => 'ro', default => 1);
has cache            => (is => 'ro', default => sub { {} });

sub run {
    my ($self, $ga) = @_;

    {
        no warnings 'redefine';
        use AI::Genetic::OpSelection;

        my $old_top_n = \&AI::Genetic::OpSelection::topN;

        *AI::Genetic::OpSelection::topN = sub {
          my $newPop = $_[0];
          $self->_run($ga, map { [$_->genes] } @$newPop);
          $old_top_n->(@_);
        }
    }

    return _run(@_);
}

sub _run {
    my $self = shift,
    my $ga = shift;
        #my @chromosomes = scalar @_ eq 1 ? [shift] : @_;
    my @chromosomes = @_;

    my $people = $ga->people;

    my %not_in_cache;

    for my $ga_chromosome (@$people, @chromosomes) {
        my $genes = ref $ga_chromosome eq 'ARRAY' ? $ga_chromosome : [$ga_chromosome->genes] ;
        my $chromosome = $self->chromosome_class->new({ genes => $genes });

        $not_in_cache{$chromosome->key} = $chromosome
          unless $self->cache->{$chromosome->key};
    }

    $self->_run_in_parallel(%not_in_cache);


    #say Dumper($self->cache) if keys %not_in_cache;

    my $current_key = $self->chromosome_class->new({ genes => $chromosomes[0] })->key;

    return $self->cache->{$current_key};
}

sub _run_in_parallel {
    my ($self, %chromosomes) = @_;

    say(scalar keys(%chromosomes) . ' chromosomes not in cache') if keys %chromosomes;

    my $pm = Parallel::ForkManager->new(30);

    $pm->run_on_finish (
        sub {
            my ($pid, $exit_code, $ident, $exit_signal, $core_dump, $data) = @_;

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
