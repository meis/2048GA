package AI::Genetic::Pro::Parallel;
use base qw(AI::Genetic::Pro);
use Parallel::ForkManager;

sub _calculate_fitness_all {
    my ($self) = @_;

    $self->_fitness( { } );
    my $pm = Parallel::ForkManager->new(4 * $self->forks_x_dir);

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
}
1;
