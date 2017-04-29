# -*- mode: perl -*-
requires 'AI::Genetic';
requires 'Data::Dumper';
requires 'List::Util';
requires 'Module::Load';
requires 'Moo';
requires 'Moo::Role';

on 'develop' => sub {
    requires 'App::Prove';
    requires 'App::Prove::Watch';
    requires 'Carp';
    requires 'Devel::NYTProf';
    requires 'Test::More';
};
