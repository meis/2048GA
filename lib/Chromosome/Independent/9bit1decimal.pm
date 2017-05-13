package Chromosome::Independent::9bit1decimal;
use v5.10;
use strict;
use warnings;
use Moo;

with 'Chromosome::Independent';

sub _build_bits    { 9 }
sub _build_decimal { 1 }

1;
