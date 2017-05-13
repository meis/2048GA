package Chromosome;
use v5.10;
use strict;
use warnings;
use Data::Dumper;
use Moo::Role;

requires '_build_weights';
requires 'crossover';
requires 'mutate';

has weights => (is => 'lazy');
has key     => (is => 'lazy');
has fitness => (is => 'rw', default => undef);

sub weight_keys {
    return qw(
        position
        score
        empty_tiles
        tile_value
        tile_neighbours
        tile_empty_neighbours
        tile_min_distance
        tile_max_distance
    );
}

sub _build_key {
    my $self = shift;

    return join(',', map { $self->weights->{$_} } $self->weight_keys);
};

sub to_string {
    my $self = shift;

    local $Data::Dumper::Terse = 1;
    Dumper($self->weights);
}

1;
