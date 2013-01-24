package SoundSwarm::Daemon::Queue;

use SoundSwarm::Syntax;
use Moo;

has port => (
	is      => 'lazy',
	isa     => Int,
	default => sub { SoundSwarm::QUEUE_PORT },
);

has host => (
	is      => 'lazy',
	isa     => Str,
	default => sub { '127.0.0.1' },
);

has queue => (
	is      => 'ro',
	isa     => ArrayRef,
	default => sub { [] },
);

with qw(
	MooseX::ConstructInstance
	SoundSwarm::Role::Logging
	SoundSwarm::Role::Daemon::JSONRPC
	SoundSwarm::Role::Daemon
);

sub is_valid_method
{
	my ($self, $method) = @_;
	{
		enqueue    => 1,
		dequeue    => 1,
		empty      => 1,
		size       => 1,
		list       => 1,
		peek       => 1,
	}->{$method};
}

sub enqueue
{
	my $self = shift;
	push @{ $self->queue }, @_;
	return;
}

sub dequeue
{
	my $self = shift;
	return shift @{ $self->queue };
}

sub empty
{
	my $self = shift;
	return not scalar @{ $self->queue };
}

sub size
{
	my $self = shift;
	return scalar @{ $self->queue };
}

sub peek
{
	my $self = shift;
	return if $self->empty;
	return $self->queue->[0];
}

sub list
{
	my $self = shift;
	return $self->queue;
}

1;

