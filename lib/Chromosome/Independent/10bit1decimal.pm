package Chromosome::Independent::10bit1decimal;
use v5.10;
use strict;
use warnings;
use Moo;

=head1 NAME

Chromosome::Independent::10bit - Value Independent Chromosome using 10 bits to
encode each weight with one decimal.

=cut

with 'Chromosome::Independent';

sub _build_bits    { 10 }
sub _build_decimal { 1 }

1;
