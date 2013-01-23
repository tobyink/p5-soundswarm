package SoundSwarm::Daemon::Library;

use SoundSwarm::Syntax;
use Moo;
use SoundSwarm::Data;

has port => (
	is      => 'lazy',
	isa     => Int,
	default => sub { 4244 },
);

has host => (
	is      => 'lazy',
	isa     => Str,
	default => sub { '127.0.0.1' },
);

has track_orm_class => (
	is      => 'lazy',
	isa     => Str,
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
		random_track   => 1,
		search_tracks  => 1,
	}->{$method};
}

sub _build_track_orm_class
{
	return "SoundSwarm::Data::Track";
}

sub random_track
{
	my $self = shift;
	($self->track_orm_class->select('ORDER BY RANDOM() LIMIT 1'))[0];
}

sub search_tracks
{
	my $self = shift;
	my ($params) = @_;
	[ $self->track_orm_class->search(%$params) ];
}

1;

