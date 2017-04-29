#!/usr/bin/env perl
use v5.10;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Chromosome::40Bits;
use Player;

my $tests = 100;
my @times = (2000, 1000, 500, 100, 50, 20, 10);
my @deviation  = map { 0 } @times;

for my $test (1..$tests) {
    my $bits = [ map { int(rand(2)) % 2} 0..39 ];
    my @fitnesses;

    my $n = 0;
    for my $how_much (@times) {
        my $chromosome = Chromosome::40Bits->new({ genes => $bits });
        my $player = Player->new({ chromosome => $chromosome });
        my $fitness = $player->play($how_much);

        push @fitnesses, $fitness;
        my $diff = (($fitness - $fitnesses[0]) / (($fitness + $fitnesses[0]) / 2)) * 100;
        $deviation[$n++] += abs $diff;
    }
}


say "Deviation";
for my $d (0..@times -1) {
    say " " . $times[$d] . ' ' . $deviation[$d] / $tests;
}
