#!/usr/bin/env perl
use v5.10;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Board;
use Chromosome::Dummy;
use Player;

my $number_of_plays = shift || 1;
my @chromosome_data = split(',', shift);

my $chromosome = Chromosome::Dummy->new({
    weights => { map { $_ => shift @chromosome_data } Chromosome::Dummy->weight_keys }
});

my $score = Player->new({ chromosome => $chromosome })->play($number_of_plays);

say "Average score: $score";
