package Chromosome::Independent::9bit;
use v5.10;
use strict;
use warnings;
use Moo;

=head1 NAME

Chromosome::Independent::9bit - Value Independent Chromosome using 9 bits to
encode each weight.

=cut

with 'Chromosome::Independent';

sub _build_bits    { 9 }
sub _build_decimal { 0 }

1;
