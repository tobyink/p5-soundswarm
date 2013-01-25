package App::SoundSwarm::Command::skip;

use strict;
use warnings;
use App::SoundSwarm -command;

sub abstract
{
	return "skip the current track";
}

sub command_names
{
	return qw( skip skidoodle );
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
		[ "port=i"  => "TCP port to connect to (default ${\SoundSwarm::PLAYER_PORT()})" ],
		[ "host=s"  => "host to connect to" ],
	);
}

sub execute
{
	require SoundSwarm::Client::Player;
	
	my ($self, $opt, $args) = @_;
	my $player = "SoundSwarm::Client::Player"->new(%$opt);
	print $player->skip->{status}, "\n";
}

1;

