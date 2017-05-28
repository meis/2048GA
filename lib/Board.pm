package Board;
use v5.10;
use strict;
use warnings;

=head1 NAME

Board - Immutable Board to play 2048.

=head1 SYNOPSIS

    use Board;

    my $board = Board->new;

    my $possible_moves = $board->possible_moves;

    while (! $board->finished) {
        $board = $board->move('left');
    }

    print "Final score is: " . $board->score . "\n";

=head1 DESCRIPTION

This class represents a 2048 board and implements all the game logic. Any board
has C<tiles> and C<score>.

The C<tiles> are encoded in an unidimensional array. For performance, tile
values are expressed as exponents. Thus, if the tile contains a 4 represents
a 16, and a value of 5 represents a 32.

The C<moves> method returns all the Boards that can be reached from this one.
To get the move keys (left, right, up, down) you can use C<possible_moves>. If
you C<move> to any of those directions, you will get a new Board (the one
with that direction key in C<moves> with an extra random tile);

=cut

use constant ROTATION => {
    left  => [ 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 ],
    right => [ 3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12 ],
    up    => [ 0,4,8,12,1,5,9,13,2,6,10,14,3,7,11,15 ],
    down  => [ 12,8,4,0,13,9,5,1,14,10,6,2,15,11,7,3 ],
};

sub new {
    my ($self, $args) = @_;

    $args ||= {};
    my $board = bless $args, $self;

    unless ($board->{tiles}) {
        $board->{tiles} = [qw/
            0 0 0 0
            0 0 0 0
            0 0 0 0
            0 0 0 0
        /];

        $board->_add_random_tile($board);
        $board->_add_random_tile($board);
    }

    $board->{score} ||= 0;

    return $board;
}

sub finished {
    my $self = shift;

    return (0 == $self->available_moves);
}

sub move {
    my ($self, $direction) = @_;

    die "Game ended" if $self->finished;

    my @moves = $self->available_moves;
    die "Not allowed" unless grep { $direction eq $_ } @moves;

    my $new_board = $self->moves->{$direction};
    $new_board->_add_random_tile();

    return $new_board;
}

sub tiles { shift->{tiles} }
sub score { shift->{score} }
sub moves {
    my $self = shift;

    if (!$self->{moves}) {
        $self->{moves} = $self->_build_moves;
    }

    $self->{moves};
}

sub available_moves {
    my $self = shift;

    keys %{ $self->moves };
}

sub _add_random_tile {
    my $self = shift;

    my $tiles = $self->{tiles};

    my @free_cells = grep { !$tiles->[$_] } 0..@$tiles -1;
    # 90% of values are "2", 10% are "4"
    my $tile_value = int(1.1 + rand(1));
    my $random_position = @free_cells[rand @free_cells];

    $tiles->[$random_position] = $tile_value;
}

sub _build_moves {
    my $self = shift;
    my $moves = {};

    for my $direction (keys %{(ROTATION)}) {
        my $state = $self->_move_tiles($direction);
        $moves->{$direction} = $state
            unless $self->_equals($state);
    }

    return $moves;
}

sub _equals {
    my ( $self, $other ) = @_;

    for (0..15) {
        return 0 if $self->tiles->[$_] != $other->tiles->[$_];
    }

    return 1;
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

sub _move_tiles {
    my ( $self, $direction ) = @_;

    my $new;
    my @tiles = @{$self->tiles};
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
            $tiles[$r[0]],
            $tiles[$r[1]],
            $tiles[$r[2]],
            $tiles[$r[3]]
        );

        $score += $added_score;
    }

    return __PACKAGE__->new({
        tiles => $new,
        score => $score
    });
}

1;
