package App::SoundSwarm::Command::search;

use strict;
use warnings;
use App::SoundSwarm -command;
use PerlX::Maybe;

sub abstract
{
	return "search for files in the library";
}

sub command_names
{
	return qw( search s );
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
		[ "port=i"          => "TCP port to connect to (default ${\SoundSwarm::LIBRARY_PORT()})" ],
		[ "host=s"          => "host to connect to" ],
		[ "filename|f=s@"   => "search filenames" ],
		[ "title|t=s@"      => "search track titles" ],
		[ "artist|a=s@"     => "search artists" ],
		[ "album|l=s@"      => "search albums" ],
	);
}

sub execute
{
	require SoundSwarm::Client::Library;
	
	my ($self, $opt, $args) = @_;
	
	$self->usage_error("please search for something specific")
		unless $opt->filename || $opt->title || $opt->artist || $opt->album;
	
	my $library = "SoundSwarm::Client::Library"->new({
		maybe port => $opt->port,
		maybe host => $opt->host,
	});
	
	my $results = $library->search_tracks({
		maybe filename => $opt->filename,
		maybe title    => $opt->title,
		maybe artist   => $opt->artist,
		maybe album    => $opt->album,
	});
	
	print "$_->{filename}\n" for @$results;
}

1;

