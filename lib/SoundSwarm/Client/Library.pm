package SoundSwarm::Client::Library;

use SoundSwarm::Syntax;
use Moo;

has port => (
	is      => 'lazy',
	isa     => Int,
	default => sub { SoundSwarm::LIBRARY_PORT },
);

has host => (
	is      => 'lazy',
	isa     => Str,
	default => sub { '127.0.0.1' },
);

with qw(
	MooseX::ConstructInstance
	SoundSwarm::Role::Logging
	SoundSwarm::Role::Client
	SoundSwarm::Role::Client::JSONRPC
);

__PACKAGE__->__proxy(qw(
	random_track
	search_tracks
));

1;

