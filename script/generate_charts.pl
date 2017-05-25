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

my $directory = shift || 'output';

my @reports = <$directory/*.csv>;
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

    small_chart($tmp_file, $file);
    big_chart($tmp_file, $file);

    `rm $tmp_file`;
}

sub small_chart {
    my ($csv, $original_name) = @_;

    my $chart = $original_name;
    $chart =~ s/csv/small.png/;

    custom_chart($csv, $chart, "size 550,150 font 'Arial,7'");
}

sub big_chart {
    my ($csv, $original_name) = @_;

    my $chart = $original_name;
    $chart =~ s/csv/big.png/;

    custom_chart($csv, $chart, "size 1200,600 font 'Arial,14'");
}

sub custom_chart {
    my ($csv, $chart_name, $png_options) = @_;

    `gnuplot -e "
        set datafile separator ','; \
        set term png $png_options; \
        set output '$chart_name'; \
        set key right bottom; \
        set xlabel 'Generació'; \
        plot '$csv' using 2 title 'Aptitud màxima' with lines, \
             '$csv' using 3 title 'Aptitud mitjana' with lines; \
    "`;
}
