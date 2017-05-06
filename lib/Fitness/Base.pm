package Fitness::Base;
use v5.10;
use strict;
use Moo;
use Chromosome;
use Player;

has play    => (is => 'ro', default => 1);
has bits    => (is => 'ro', default => 8);
has decimal => (is => 'ro', default => 0);

sub run {
    my ($self, $ga, $genes) = @_;

    my $chromosome = Chromosome->new({
        genes   => $genes,
        bits    => $self->bits,
        decimal => $self->decimal,
    });

    my $player = Player->new({ chromosome => $chromosome });
    $player->play($self->play);
}

1;
