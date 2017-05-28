#!/bin/env perl
use v5.10;
use strict;
use Test::More;
use List::Util qw/sum/;

use Chromosome::0Sum::5000Genes;

subtest '5000 genes' => sub {
    my $chromosome = Chromosome::0Sum::5000Genes->new();

    is(scalar @{$chromosome->genes}, 5000);

    my $sum_of_weights = sum values %{$chromosome->weights};
    is($sum_of_weights, 0);

    # All genes should have a weight as value
    my $valid_genes = grep { $_ } map {
        my $gene = $_;
        map { $_ eq $gene } $chromosome->gene_values
    } @{$chromosome->genes};
    is($valid_genes, 5000);
};

done_testing();
