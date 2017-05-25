# -*- mode: perl -*-
requires 'Cache::LRU';
requires 'Data::Dumper';
requires 'FindBin';
requires 'Getopt::Long::Descriptive';
requires 'List::Util';
requires 'List::MoreUtils';
requires 'MIME::Base64';
requires 'Module::Load';
requires 'Moo';
requires 'Moo::Role';
requires 'Parallel::ForkManager';
requires 'Paws';
requires 'Statistics::Basic';

on 'develop' => sub {
    requires 'App::Prove';
    requires 'App::Prove::Watch';
    requires 'Devel::NYTProf';
    requires 'Test::More';
    requires 'Text::CSV';
};
