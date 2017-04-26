package Chromosome;
use v5.10;
use strict;
use warnings;
use Moo::Role;

requires 'init';
requires 'type';

has genes   => (is => 'lazy');
has weights => (is => 'lazy');

1;
