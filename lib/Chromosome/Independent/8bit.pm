package Chromosome::Independent::8bit;
use v5.10;
use strict;
use warnings;
use Moo;

=head1 NAME

Chromosome::Independent::8bit - Value Independent Chromosome using 8 bits to
encode each weight.

=cut

with 'Chromosome::Independent';

sub _build_bits    { 8 }
sub _build_decimal { 0 }

1;
