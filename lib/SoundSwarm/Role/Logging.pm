package SoundSwarm::Role::Logging;

use SoundSwarm::Syntax;
use MooX::Role;

sub log {
	my ($self, $fmt, @args) = @_;
	printf STDERR "$fmt\n", @args;
}

1;
