package Fitness::Base;
use v5.10;
use strict;
use Moo;
use Minion::Individual;

has chromosome_class => (is => 'ro', requrired => 1);
has play             => (is => 'ro', default => 1);

sub run {
    my ($self, $ga, $genes) = @_;

    my $chromosome = $self->chromosome_class->new({
        genes => $genes
    });

    my $player = Minion::Individual->new({ chromosome => $chromosome });
    $player->play($self->play);
}

1;
