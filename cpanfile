# -*- mode: perl -*-
requires 'AI::Genetic';
requires 'Cache::LRU';
requires 'Data::Dumper';
requires 'Getopt::Long::Descriptive';
requires 'List::Util';
requires 'Module::Load';
requires 'Moo';
requires 'Moo::Role';
requires 'Parallel::ForkManager';
requires 'Statistics::Basic';

on 'develop' => sub {
    requires 'App::Prove';
    requires 'App::Prove::Watch';
    requires 'Carp';
    requires 'Devel::NYTProf';
    requires 'Test::More';
};
