package Minion::Breed;
use v5.10;
use strict;
use AI::Genetic;
use Minion::Individual;
use List::MoreUtils qw/natatime/;
use Data::Dumper;
use Bit::Vector;

sub start {
    my $ga = AI::Genetic->new(
        -fitness         => \&_fitness,        # fitness function
        -type            => 'bitvector',      # type of chromosomes
        -population      => 10,             # population
        -crossover       => 0.9,              # probab. of crossover
        -mutation        => 0.01,             # probab. of mutation
        -parents         => 2,                # number  of parents
        -selection       => [ 'Roulette' ],   # selection strategy
        -strategy        => [ 'Points', 2 ],  # crossover strategy
        -cache           => 0,                # cache results
        -history         => 1,                # remember best results
        -preserve        => 3,                # remember the bests
        -variable_length => 1,                # turn variable length ON
    );

    # init population of 32-bit vectors
    $ga->init(16 * 5);
    #      # evolve 10 generations
    $ga->evolve('rouletteTwoPoint', 3);
    #       # best score
    print "SCORE: ", $ga->getFittest, ".\n";
    say Dumper($ga->getFittest);
}

sub _fitness {
    my ($chromosome) = @_;

    my $weights = _chromosome_to_weights($chromosome);
    Minion::Individual->new->play(100, $weights);
}

sub _chromosome_to_weights {
    my $chromosome = shift;

    my $weights = [];

    my $it = natatime 16, @$chromosome;
    while (my @vals = $it->()) {
        #push @$weights, unpack('f', pack('b32', join('', @vals)));
        push @$weights, Bit::Vector->new_Bin(16, join('', @vals))->to_Dec / 1000;
    }

    #    my $bitarray = '0b' . join('',@$chromosome);
    #use Data::Dumper;
    #    say $bitarray;
    #    say Dumper(unpack('d', pack('b64', $bitarray)));
    #    [ 3, 2, 0.00001, 3, 0.3];
    say Dumper($weights);
    $weights;
}

1;
