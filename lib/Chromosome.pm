package Chromosome;
use v5.10;
use strict;
use warnings;
use Data::Dumper;
use Moo;

has bits    => (is => 'ro', default => 8);
has decimal => (is => 'ro', default => 0);
has genes   => (is => 'lazy');
has weights => (is => 'lazy');

sub key  { join('', @{shift->genes}) }
sub to_string {
    my $self = shift;
    local $Data::Dumper::Terse = 1;
    Dumper($self->weights);
}

sub _build_genes  {[ map {0} 1..(8 * shift->bits) ]}

sub _build_weights {
    my $self = shift;

    my @genes = @{$self->genes};

    my $votes = $self->bits / 3;

    my $encoded_weights = [];

    my $bit_index = 0;
    for my $i (1..$votes) {
        my $ammount = $i % 2 == 0 ? 1 : -1;

        $encoded_weights->[$genes[$bit_index++]]
                        ->[$genes[$bit_index++]]
                        ->[$genes[$bit_index++]] += $ammount;
    }

    return  {
        position              => $encoded_weights->[0][0][0] || 0,
        score                 => $encoded_weights->[0][0][1] || 0,
        empty_tiles           => $encoded_weights->[0][1][0] || 0,
        tile_value            => $encoded_weights->[0][1][1] || 0,
        tile_neighbours       => $encoded_weights->[1][0][0] || 0,
        tile_empty_neighbours => $encoded_weights->[1][0][1] || 0,
        tile_min_distance     => $encoded_weights->[1][1][0] || 0,
        tile_max_distance     => $encoded_weights->[1][1][1] || 0,
    };
}

1;
