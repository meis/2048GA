package Fitness::Base;
use v5.10;
use strict;
use Moo;

has chromosome_class => (is => 'ro');
has play => (is => 'ro');

sub run {
    my ($self, $ga, $bits) = @_;

    say $self->play;
    $self->chromosome_class->new({
        bits => $bits
    })->build_individual->play($self->play);
}

1;
