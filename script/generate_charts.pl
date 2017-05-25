#!/usr/bin/env perl
use v5.10;
use strict;
use warnings;
use autodie;

use FindBin;
use lib "$FindBin::Bin/../lib";

use List::Util qw/max/;
use File::Basename;
use Statistics::Basic qw(:all);
use Text::CSV;

my @reports = <output/*.csv>;
foreach my $file (@reports) {
  my ($file_name) = fileparse($file);

  my $generations = [];

  my $csv = Text::CSV->new ( { binary => 1 } );
  open my $fh, "<:encoding(utf8)", $file;
  $csv->getline( $fh );
  while ( my $row = $csv->getline( $fh ) ) {
    push @{$generations->[$row->[0]]}, $row->[1];
  }
  close $fh;

  my $tmp_file = 'test.csv';
  open(my $tmp_fh, ">", $tmp_file);
  my $i = 0;
  for my $generation (@$generations) {
    $csv->print ($tmp_fh, [$i++, max(@$generation) + 0, mean(@$generation) + 0] );
    print $tmp_fh "\n";
  }

  my $chart = $file;
  $chart =~ s/csv/png/;

  `gnuplot -e "
    set term png size 1000,350; \
    set datafile separator ','; \
    set output '$chart'; \
    set key right bottom; \
    set xlabel 'Generació'; \
    plot '$tmp_file' using 2 title 'Aptitud màxima' with lines, \
         '$tmp_file' using 3 title 'Aptitud mitjana' with lines; \
         "`;
  `rm $tmp_file`;
}
