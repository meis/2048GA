#!/usr/bin/env perl
use v5.10;
use strict;
use warnings;
use Data::Dumper;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Getopt::Long::Descriptive;
use Experiment;

local $Data::Dumper::Pair = ': ';
local $Data::Dumper::Varname = 'params';
local $Data::Dumper::Indent = 1;

my ($opt, $usage) = describe_options(
  'run_experiment.pl %o <some-arg>',
  [ 'generations=i', "Number of generations",       { default => 100 } ],
  [ 'population=i',  "Players in each generation",  { default => 100 } ],
  [ 'games=i',       "Number of games for fitness", { default => 10 } ],
  [],
  [ 'crossover=f', "Crossover rate",     { default => 0.95 } ],
  [ 'mutation=f',  "Mutation rate",      { default => 0.05 } ],
  [ 'strategy=s',  "Evolution Strategy", { default => 'rouletteUniform' } ],
  [],
  [ 'bits=i',    "Number of bits to use in Chromosome",{ default => 8 } ],
  [ 'decimal=i', "Decimal part of the Chromosome",     { default => 0 } ],
  [],
  [ 'fitness_class=s',    "Fitness class to use",    { default => 'Base' } ],
  [],
  [ 'file=s', "Save output to file" ],
  [],
  [ 'help|h', "print usage message and exit", { shortcircuit => 1 } ],
);

if ($opt->help) {
    say($usage->text);
}
else {
    say "Running experiment with params:";
    say Dumper({%$opt});

    if ($opt->file) {
        open STDOUT, '>', $opt->file;
    }

    Experiment->new({%$opt})->run();
}

