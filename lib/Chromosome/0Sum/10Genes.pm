package Chromosome::0Sum::10Genes;
use v5.10;
use strict;
use warnings;
use Moo;

=head1 NAME

Chromosome::0Sum::10Genes - 0Sum Chromosome with 10 genes.

=cut

with 'Chromosome::0Sum';

sub _build_size { 10 }

1;

