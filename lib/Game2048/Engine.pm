package Game2048::Engine;
use v5.10;
use strict;
use Moo;
use Game2048::State;

has state => ( is => 'rw', builder => 1);

sub finished {
    my $self = shift;

    return ( 0 == $self->state->available_moves );
}

sub move {
    my ( $self, $direction ) = @_;

    die "Game ended" if $self->finished;

    my @moves = $self->state->available_moves;
    die "Not allowed" unless grep { $direction eq $_ } @moves;

    my $new_state = $self->state->moves->{$direction};
    my $new_board = $new_state->board;

    $self->state(
        Game2048::State->new({
            board => $self->_add_random_tile($new_board),
            score => $new_state->score,
        })
    );
}

sub _build_state {
    my $self = shift;

    my $board = [qw/
        0 0 0 0
        0 0 0 0
        0 0 0 0
        0 0 0 0
    /];

    $self->_add_random_tile($board);
    $self->_add_random_tile($board);

    return Game2048::State->new({ board => $board });
}

sub _add_random_tile {
    my ( $self, $board ) = @_;

    my @free_cells = grep { !$board->[$_] } 0..@$board -1;
    # 90% of values are "2", 10% are "4"
    my $tile_value = int(1.1 + rand(1));
    my $random_position = @free_cells[rand @free_cells];

    $board->[$random_position] = $tile_value;

    return $board;
}

1;
