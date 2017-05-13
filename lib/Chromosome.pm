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

    my $weights = {
        position              => 0,
        score                 => 0,
        empty_tiles           => 0,
        tile_value            => 0,
        tile_neighbours       => 0,
        tile_empty_neighbours => 0,
        tile_min_distance     => 0,
        tile_max_distance     => 0,
    };

    my $encoded_weights = $self->bits / 3;

    for my $i (1..$encoded_weights) {
        my $ammount = $i % 2 == 0 ? 1 : -1;
        my $weight = $self->_decode_weight(splice(@genes, 0, 3));

        $weights->{$weight} += $ammount;
    }

    return $weights;
}

sub _decode_weight {
    my ($self, @bits) = @_;

    if ($bits[0]) {
        if ($bits[1]) {
            if ($bits[2]) {
                return 'tile_max_distance'
            }
            else {
                return 'tile_min_distance'
            }
        }
        else {
            if ($bits[2]) {
                return 'tile_empty_neighbours'
            }
            else {
                return 'tile_neighbours'
            }
        }
    }
    else {
        if ($bits[1]) {
            if ($bits[2]) {
                return 'tile_value'
            }
            else {
                return 'empty_tiles'
            }
        }
        else {
            if ($bits[2]) {
                return 'score'
            }
            else {
                return 'position'
            }
        }
    }
}

1;
