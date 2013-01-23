package SoundSwarm::Client::Queue;

use SoundSwarm::Syntax;
use Moo;

has port => (
	is      => 'lazy',
	isa     => Int,
	default => sub { 4243 },
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
	enqueue
	dequeue
	empty
	size
	list
	peek
));

1;

