package Game2048::State;
use v5.10;
use strict;
use Moo;

has board => ( is => 'ro', required => 1 );
has score => ( is => 'ro', default => 0 );
has moves => ( is => 'lazy' );

use constant ROTATION => {
    left  => [ 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 ],
    right => [ 3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12 ],
    up    => [ 0,4,8,12,1,5,9,13,2,6,10,14,3,7,11,15 ],
    down  => [ 12,8,4,0,13,9,5,1,14,10,6,2,15,11,7,3 ],
};

sub available_moves {
    my $self = shift;

    keys %{ $self->moves };
}

sub _build_moves {
    my $self = shift;
    my $moves = {};

    for my $direction (keys %{(ROTATION)}) {
        my $state = $self->_move_board($direction);
        $moves->{$direction} = $state
            unless $self->_equals($state);
    }

    return $moves;
}

sub _equals {
    my ( $self, $other ) = @_;

    !grep {
        $self->board->[$_] != $other->board->[$_]
    } 0..15;
}

sub _shift_row {
    my ( $self, @tiles ) = @_;

    # Not null tiles, this moves all left
    @tiles = grep {$_} @tiles;
    # Complete void tiles
    $tiles[$_] = 0 for (@tiles..3);

    my $score = 0;

    # Join pairs
    for my $p ( [0,1], [1,2], [2,3] ) {
        next unless $tiles[$p->[0]] && $tiles[$p->[1]];
        if ( $tiles[$p->[0]] == $tiles[$p->[1]] ) {
            $tiles[$p->[0]] += 1;
            $tiles[$p->[1]] = 0;
            $score += 2 ** $tiles[$p->[0]];
        }
    }

    # Move null tiles to right and count free cells
    @tiles = grep {$_} @tiles;
    $tiles[$_] = 0 for (@tiles..3);

    return @tiles, $score;
}

sub _move_board {
    my ( $self, $direction ) = @_;

    my $new;
    my @board = @{$self->board};
    my $score = $self->score;

    my $idx = 0;
    for (0..3) {
        my @r = (
            ROTATION->{$direction}->[$idx++],
            ROTATION->{$direction}->[$idx++],
            ROTATION->{$direction}->[$idx++],
            ROTATION->{$direction}->[$idx++],
        );

        (
            $new->[$r[0]],
            $new->[$r[1]],
            $new->[$r[2]],
            $new->[$r[3]],
            my $added_score,
        ) = $self->_shift_row(
            $board[$r[0]],
            $board[$r[1]],
            $board[$r[2]],
            $board[$r[3]]
        );

        $score += $added_score;
    }

    return __PACKAGE__->new({
        board => $new,
        score => $score
    });
}

1;
