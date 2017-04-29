package Chromosome;
use v5.10;
use strict;
use warnings;
use Data::Dumper;
use Moo::Role;

requires 'init';
requires 'type';
requires 'key';

has genes   => (is => 'lazy');
has weights => (is => 'lazy');

sub to_string {
    my $self = shift;
    local $Data::Dumper::Terse = 1;
    Dumper($self->weights);
}

1;
