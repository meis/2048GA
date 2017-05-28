package Chromosome::0Sum::1000Genes;
use v5.10;
use strict;
use warnings;
use Moo;

=head1 NAME

Chromosome::0Sum::1000Genes - 0Sum Chromosome with 1000 genes.

=cut

with 'Chromosome::0Sum';

sub _build_size { 1000 }

1;

