package Minion::Board;
use v5.10;
use strict;
use Moo;
use Game2048::Engine;
use Game2048::Evaluator;

use Data::Dumper;

has weights => ( is => 'ro', default => sub { [1, 1, 1, 1, 1, 1, 1, 1] } );
has state   => ( is => 'ro' );
has board   => ( is => 'lazy' );
has score   => ( is => 'lazy' );

#  0  1  2  3
#  4  5  6  7
#  8  9 10 11
# 12 13 14 15
use constant ADJACENT => {
    0  => [ 1,  4],
    1  => [ 0,  2,  5],
    2  => [ 1,  3,  6],
    3  => [ 2,  7],
    4  => [ 0,  5,  8],
    5  => [ 1,  4,  6,  9],
    6  => [ 2,  5,  7, 10],
    7  => [ 3,  6, 11],
    8  => [ 4,  9, 12],
    9  => [ 5,  8, 13, 10],
    10 => [ 6,  9, 14, 11],
    11 => [ 7, 10, 15],
    12 => [ 8, 13],
    13 => [ 9, 12, 14],
    14 => [10, 13, 15],
    15 => [11, 14],
};

sub _build_board { shift->state->board }
sub _build_score { shift->state->score }

sub position_weight { shift->weights->[0] }
sub empty_tiles_weight { shift->weights->[1] }
sub score_weight { shift->weights->[2] }

sub tile_value_weight { shift->weights->[3] }
sub tile_neighbours_weight { shift->weights->[4] }
sub tile_empty_neighbours_weight { shift->weights->[5] }
sub tile_min_distance_weight { shift->weights->[6] }
sub tile_max_distance_weight { shift->weights->[7] }

sub evaluate {
    my $self = shift;

    return $self->__tiles + $self->__empty_tiles + $self->__score;
}

sub __tiles {
    my $self = shift;

    my $tiles = $self->_tiles_by_value;
    my $evaluation = 0;

    for my $position (0..15) {
        $evaluation += $tiles->[$position] * ($position + 1) * $self->position_weight;
    }

    return $evaluation;
}

sub _tiles_by_value {
    my $self = shift;

    return [
        sort { $a <=> $b }
        map { $self->__tile_total($_) } 0..15
    ];
}

sub __score {
    my $self = shift;

    return $self->score * $self->score_weight;
}

sub __empty_tiles {
    my $self = shift;

    return (grep { $_ == 0 } @{$self->board}) * $self->empty_tiles_weight;
}

sub __tile_total {
    my ($self, $tile) = @_;

    $self->__tile__value($tile) +
    $self->__tile__neighbours($tile) +
    $self->__tile__empty_neighbours($tile) +
    $self->__tile__min_distance($tile) +
    $self->__tile__max_distance($tile) ;
}

sub __tile__value {
    my ($self, $tile) = @_;

    my $value = $self->board->[$tile];

    return $value ? (2 ** $value) * $self->tile_value_weight : 0;
}

sub __tile__neighbours {
    my ($self, $tile) = @_;

    return @{ ADJACENT->{$tile} } * $self->tile_neighbours_weight;
}

sub __tile__empty_neighbours {
    my ($self, $tile) = @_;

    return $self->tile_empty_neighbours_weight *
        grep { $self->board->[$_] == 0 } @{ ADJACENT->{$tile} }
}

sub __tile__min_distance {
    my ($self, $tile) = @_;

    my @distances = $self->_tile_distances($tile);

    return 0 if $self->board->[$tile] == 0;
    return 0 if @distances == 0;

    return $distances[0] * $self->tile_max_distance_weight;
}

sub __tile__max_distance {
    my ($self, $tile) = @_;

    my @distances = $self->_tile_distances($tile);

    return 0 if $self->board->[$tile] == 0;
    return 0 if @distances == 0;

    return $distances[-1] * $self->tile_max_distance_weight;
}

sub _tile_distances {
    my ($self, $tile) = @_;

    sort
    map { abs($self->board->[$tile] - $_) }
    # Skip empty tiles
    grep { $_ }
    map { $self->board->[$_] }
    @{ ADJACENT->{$tile} }
}

1;
