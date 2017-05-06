#!/usr/bin/env perl
use v5.10;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Chromosome;
use Player;
use List::Util qw/max/;
use Statistics::Basic qw(:all);

my $tests = 100;
my @times = (2000, 1000, 500, 100, 50, 20, 10, 5, 1);
my @deviations = map { [] } @times;

for my $test (1..$tests) {
    my $bits = [ map { int(rand(2)) % 2} 0..39 ];
    my $reference;

    my $n = 0;

    for my $how_much (@times) {
        my $chromosome = Chromosome->new({ genes => $bits });
        my $player = Player->new({ chromosome => $chromosome });
        my $fitness = $player->play($how_much);

        if ($n == 0) {
            $reference = $fitness;
        }
        else {
            my $diff = (($fitness - $reference) / (($fitness + $reference) / 2)) * 100;
            push @{$deviations[$n]}, abs $diff;
        }

        $n++;
    }
}

say "Deviations:";
for my $d (1..@times -1) {
    say '* Playing ' . sprintf("%5s", $times[$d]) . ' times:'
      . '  Mean: '   . sprintf("%03.2f%", mean @{$deviations[$d]})
      . '  Max: '    . sprintf("%03.2f%", max @{$deviations[$d]})
      . '  Std: '    . sprintf("%03.2f%", stddev @{$deviations[$d]});
}
