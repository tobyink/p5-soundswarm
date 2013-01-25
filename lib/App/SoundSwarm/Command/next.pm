package App::SoundSwarm::Command::next;

use strict;
use warnings;
use App::SoundSwarm -command;
use PerlX::Maybe;

sub abstract
{
	return "show information about the next track in the queue";
}

sub command_names
{
	return qw( next );
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
		[ "port=i"          => "TCP port to connect to (default ${\SoundSwarm::QUEUE_PORT()})" ],
		[ "host=s"          => "host to connect to" ],
		[ "library-port=i"  => "TCP port to connect to (default ${\SoundSwarm::LIBRARY_PORT()})" ],
		[ "library-host=s"  => "host to connect to" ],
	);
}

sub execute
{
	require SoundSwarm::Client::Queue;
	require SoundSwarm::Client::Library;
	
	my ($self, $opt, $args) = @_;
	
	my $player = "SoundSwarm::Client::Queue"->new({
		maybe port => $opt->port,
		maybe host => $opt->host,
	});
	my $song = $player->list->[0];
	print $song, "\n";
	
	my $library = "SoundSwarm::Client::Library"->new({
		maybe port => $opt->library_port,
		maybe host => $opt->library_host,
	});	
	my $results = $library->search_tracks({ filename => $song });
	
	my ($result) = grep $_->{filename} eq $song, @$results;
	for my $key (qw( Artist Album Title )) {
		next unless defined(my $val = $result->{lc $key});
		printf("% 8s : %s\n", $key, $val);
	}
}

1;

