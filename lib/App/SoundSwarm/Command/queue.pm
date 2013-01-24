package App::SoundSwarm::Command::queue;

use strict;
use warnings;
use App::SoundSwarm -command;

sub abstract
{
	return "examine the queue";
}

sub command_names
{
	return qw( queue q );
}

sub usage_desc
{
	my $class  = shift;
	my ($name) = $class->command_names;
	return "%c $name %o";
}

sub opt_spec
{
	require SoundSwarm;
	return (
		[ "port"    => "TCP port to connect to (default ${\SoundSwarm::QUEUE_PORT()})" ],
		[ "host"    => "host to connect to" ],
	);
}

sub execute
{
	require SoundSwarm::Client::Queue;
	require Path::Class;
	
	my ($self, $opt, $args) = @_;
	my $queue = SoundSwarm::Client::Queue->new(%$opt);
	
	print "$_\n" for @{ $queue->list };
}

1;

