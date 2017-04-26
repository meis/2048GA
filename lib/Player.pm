package Player;
use v5.10;
use strict;
use Moo;
use List::Util qw/sum/;
use Game2048::Board;

has 'chromosome' => (is => 'ro');

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

sub play {
    my $self = shift;
    my $times = shift || 1;
    my $total_score = 0;

    for (0..$times -1) {
        my $board = Game2048::Board->new;

        while (!$board->finished) {
            $board = $board->move($self->decide($board));
        }

        $total_score += $board->score;
    }

    return $total_score / $times;
}

sub evaluate {
    my ($self, $board) = @_;

    my $tiles = $board->tiles;
    my $score = $board->score;

    my $weights = $self->chromosome->weights;
    my $calcs = {};

    $calcs->{score} = $score * $weights->{score};
    $calcs->{empty_tiles} =  (grep { $_ == 0 } @{$tiles}) * $weights->{empty_tiles};

    for my $tile (0..15) {
        my $value = $tiles->[$tile];
        my $neighbours = ADJACENT->{$tile};
        my @distances =
            sort
            map { abs($value - $_) }
            # Skip empty tiles
            grep { $_ }
            map { $tiles->[$_] }
            @$neighbours;

        $calcs->{tile_value}[$tile] = $value ? (2 ** $value) * $weights->{tile_value} : 0;
        $calcs->{tile_neighbours}[$tile] = @$neighbours * $weights->{tile_neighbours};
        $calcs->{tile_empty_neighbours}[$tile] = $weights->{tile_empty_neighbours}
            * grep { $tiles->[$_] == 0 } @$neighbours;

        if ($value == 0 || @distances == 0) {
            $calcs->{tile_min_distance}[$tile] = 0;
            $calcs->{tile_max_distance}[$tile] = 0;
        }
        else {
            $calcs->{tile_min_distance}[$tile] = $distances[0] * $weights->{tile_min_distance};
            $calcs->{tile_max_distance}[$tile] = $distances[-1] * $weights->{tile_max_distance};
        }

        $calcs->{tile_total}[$tile] =
            $calcs->{tile_value}[$tile] +
            $calcs->{tile_neighbours}[$tile] +
            $calcs->{tile_empty_neighbours}[$tile] +
            $calcs->{tile_min_distance}[$tile] +
            $calcs->{tile_max_distance}[$tile] ;
    }

    $calcs->{tiles_by_value} = [
        sort { $a <=> $b }
        map { $calcs->{tile_total}[$_] } 0..15
    ];

    for my $position (0..15) {
        my $position_weight = 1 + 0.1 * ($position + 1) * $weights->{position};
        $calcs->{tile_evaluations}[$position] =
            $calcs->{tiles_by_value}->[$position] * $position_weight;
    }

    my $evaluation = sum(@{$calcs->{tile_evaluations}})
                   + $calcs->{empty_tiles}
                   + $calcs->{score};

    return wantarray ? ($evaluation, $calcs) : $evaluation;
}

sub decide {
    my ($self, $board) = @_;

    my $moves = $board->moves;

    my %moves = map {
        $_ => scalar $self->evaluate($board)
    } keys %$moves;

    my @sorted = sort { $moves{$b} <=> $moves{$a} } keys %moves;

    return $sorted[0];
}

1;
