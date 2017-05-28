package Chromosome::0Sum::5000Genes;
use v5.10;
use strict;
use warnings;
use Moo;

=head1 NAME

Chromosome::0Sum::5000Genes - 0Sum Chromosome with 5000 genes.

=cut

with 'Chromosome::0Sum';

sub _build_size { 5000 }

1;

