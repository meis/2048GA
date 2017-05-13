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
  [ 'games=i',       "Number of games for fitness", { default => 20 } ],
  [],
  [ 'crossover=f', "Crossover rate", { default => 0.95 } ],
  [ 'mutation=f',  "Mutation rate",  { default => 0.05 } ],
  [],
  [ 'chromosome=s', "Chromosome class to use" ],
  [],
  [ 'forks=i', "Number of forks",{ default => 4 } ],
  [],
  [ 'help|h', "print usage message and exit", { shortcircuit => 1 } ],
);

if ($opt->help) {
    say($usage->text);
}
else {
    say "Running experiment with params:";
    say Dumper({%$opt});

    my $file_name = 'output/experiment_'
                  . join('_', map { $_ . '=' . $opt->{$_} }
                      qw/generations population games crossover mutation/)
                  . '_' . time()
                  . '.csv';

    say "Output: $file_name";

    open STDOUT, '>', $file_name;

    Experiment->new({%$opt})->run();
}

