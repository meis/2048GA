package Chromosome::0Sum::100Genes;
use v5.10;
use strict;
use warnings;
use Moo;

=head1 NAME

Chromosome::0Sum::100Genes - 0Sum Chromosome with 100 genes.

=cut

with 'Chromosome::0Sum';

sub _build_size { 100 }

1;

