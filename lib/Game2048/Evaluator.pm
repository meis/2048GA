package Game2048::Evaluator;
use v5.10;
use strict;
use List::Util qw/max/;

sub evaluate {
    my ($state, $weights) = @_;
    my $board = $state->board;
    my $score = $state->score;

    my $free = grep { $_ == 0 } @$board;
    my $max  = max @$board;
    my $tiles = _tiles($board);

    return
        + $weights->[0] * $max
        + $weights->[1] * _in_corner($max, $tiles)
        + $weights->[2] * (_growth($tiles) / 10000)
        + $weights->[3] * ($free ? log($free) : 0 )
        + $weights->[4] * _smoothness($tiles)
#        + 3       * $max
#        + 2       * _in_corner($max, $tiles)
#        + 0.00001 * _growth($tiles)
#        + 3       * ($free ? log($free) : 0 )
#        + 0.3     * _smoothness($tiles)
        ;
}

sub _tiles {
    my $board = shift;

    return [
        [ $board->[0] , $board->[1] , $board->[2] , $board->[3] ],
        [ $board->[4] , $board->[5] , $board->[6] , $board->[7] ],
        [ $board->[8] , $board->[9] , $board->[10], $board->[11] ],
        [ $board->[12], $board->[13], $board->[14], $board->[15] ],
    ];
}

sub _growth {
    my $t = shift;

    my $s = 0;
    $s += _grows( $t->[0][0], $t->[0][1], $t->[0][2], $t->[0][3] ) * 2;
    $s += _grows( $t->[1][0], $t->[1][1], $t->[1][2], $t->[1][3] );
    $s += _grows( $t->[2][0], $t->[2][1], $t->[2][2], $t->[2][3] );
    $s += _grows( $t->[3][0], $t->[3][1], $t->[3][2], $t->[3][3] ) * 2;

    $s += _grows( $t->[0][0], $t->[1][0], $t->[2][0], $t->[3][0] ) * 2;
    $s += _grows( $t->[0][1], $t->[1][1], $t->[2][1], $t->[3][1] );
    $s += _grows( $t->[0][2], $t->[1][2], $t->[2][2], $t->[3][2] );
    $s += _grows( $t->[0][3], $t->[1][3], $t->[2][3], $t->[3][3] ) * 2;

    $s;
}

sub _grows {
    my @list = @_;
    return 0 unless my @values = map { $_ }
                                 grep {$_} @_;

    # List of 1 does not grow
    return 0 if @_ == 1;
    my $s = _sorted(@values) || _sorted(reverse @values);
    return $s * @_;
}

sub _sorted {
    my $idx = 0;
    my $last = $_[$idx];
    my $s = $last;

    while ( my $new = $_[$idx++] ) {
        return 0 if ( $new < $last );
        $s += $new * $new;
        $last = $new;
    }

    $s;
}

sub _in_corner {
    my ($max, $t) = @_;

    return $max if $t->[0][0] == $max;
    return $max if $t->[0][3] == $max;
    return $max if $t->[3][0] == $max;
    return $max if $t->[3][3] == $max;

    return 0;
}

sub _smoothness {
    my $t = shift;

    my $s = 0;
    for my $x ( 0..3 ) {
        for my $y ( 0..3 ) {
            if ( my $cell = $t->[$x][$y] ) {
                my $value = log($cell) / log(2);
                for my $vector ( ([1, 0], [0, 1] )) {
                    if ( my $target = _find_farthest( $x, $y, $vector, $t) ) {
                        my $target_value = log($target) / log(2);
                        $s -= abs($value - $target_value);
                    }
                }
            }
        }
    }
    return $s;
}

sub _find_farthest {
    my ($x, $y, $vector, $tiles) = @_;

    my $cell;

    while ( !$cell && $x <= 3 && $y <= 3 ) {
        $x += $vector->[0];
        $y += $vector->[1];
        $cell = $tiles->[$x][$y];
    }

    return $cell;
}

1;

