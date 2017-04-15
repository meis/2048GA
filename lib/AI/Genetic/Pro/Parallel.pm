package AI::Genetic::Pro::Parallel;
use base qw(AI::Genetic::Pro);
use Parallel::ForkManager;
use Carp;

sub _calculate_fitness_all {
    my ($self) = @_;

    $self->_fitness( { } );
    my $pm = Parallel::ForkManager->new(30);

    $pm->run_on_finish (
        sub {
            my ($pid, $exit_code, $ident, $exit_signal, $core_dump, $data_structure_reference) = @_;

            if (defined($data_structure_reference)) {
              $self->_fitness->{${$data_structure_reference}->[0]} += ${$data_structure_reference}->[1];
            }
        }
    );

    for my $i (0..$#{$self->chromosomes}) {
        $pm->start and next;
        my $fitness = $self->fitness()->($self, $self->chromosomes->[$i]);
        $pm->finish(0, \[$i, $fitness]);
    }

    $pm->wait_all_children;
}

sub as_value {
    my ($self, $chromosome) = @_;
    croak(q/You MUST call 'as_value' as method of 'AI::Genetic::Pro' object./)
           unless defined $_[0] and ref $_[0] and ref $_[0] eq 'AI::Genetic::Pro::Parallel';
    croak(q/You MUST pass 'AI::Genetic::Pro::Chromosome' object to 'as_value' method./)
           unless defined $_[1] and ref $_[1] and ref $_[1] eq 'AI::Genetic::Pro::Chromosome';
    return $self->fitness->($self, $chromosome);
}

1;
