package App::SoundSwarm::Command::enqueue;

use strict;
use warnings;
use App::SoundSwarm -command;

sub abstract
{
	return "add tracks to the queue (by filename)";
}

sub command_names
{
	return qw( enqueue nq );
}

sub usage_desc
{
	my $class  = shift;
	my ($name) = $class->command_names;
	return "%c $name %o [file ...]";
}

sub opt_spec
{
	require SoundSwarm;
	return (
		[ "port=i"  => "TCP port to connect to (default ${\SoundSwarm::QUEUE_PORT()})" ],
		[ "host=s"  => "host to connect to" ],
		[ "stdin|i" => "read filenames from STDIN instead of command line parameters" ],
	);
}

sub execute
{
	require SoundSwarm::Client::Queue;
	require Path::Class;
	
	my ($self, $opt, $args) = @_;
	my $queue;
	
	my @files =
		map { "$_" }
		map { -d $_ ? _expand_dir($_) : "Path::Class::File"->new($_)->absolute }
		map { chomp($_); $_ }
		(delete $opt->{stdin} ? (my @tmp = <STDIN>) : @$args);
	
	for (@files)
	{
		$self->usage_error("not a file: $_") unless -f $_;
		($queue ||= "SoundSwarm::Client::Queue"->new(%$opt))->enqueue($_);
	}
}

sub _expand_dir
{
	require Path::Class;
	
	my $dir = "Path::Class::Dir"->new($_);
	my @return;
	$dir->recurse(callback => sub
	{
		my $file = shift;
		return if $file->is_dir;
		return unless "$file" =~ /\.(ogg|mp3|mp4|m4a|3gp|flac)$/i;
		push @return, $file->absolute;
	});
	return @return;
}

1;

