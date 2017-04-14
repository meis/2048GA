# -*- mode: perl -*-
requires 'AI::Genetic::Pro';
requires 'List::Util';
requires 'Moo';
requires 'Parallel::ForkManager';

on 'develop' => sub {
    requires 'App::Prove';
    requires 'App::Prove::Watch';
    requires 'Devel::NYTProf';
    requires 'Test::More';
};
