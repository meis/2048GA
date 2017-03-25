# -*- mode: perl -*-
requires 'Moo';

on 'develop' => sub {
    requires 'Test::More';
    requires 'App::Prove';
    requires 'App::Prove::Watch';
};
