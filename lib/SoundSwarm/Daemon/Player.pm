package SoundSwarm::Daemon::Player;

use SoundSwarm::Syntax;
use Moo;

has port => (
	is      => 'lazy',
	isa     => Int,
	default => sub { 4242 },
);

has host => (
	is      => 'lazy',
	isa     => Str,
	default => sub { '127.0.0.1' },
);

has queue_management_process => (
	is      => 'rwp',
	isa     => InstanceOf[ 'Async' ],
);

has mplayer => (
	is      => 'lazy',
	isa     => InstanceOf[ 'SoundSwarm::MPlayer' ],
	handles => {
		play       => 'play',
		skip       => 'stop',
		pause      => 'pause',
		wait       => 'wait',
		is_playing => 'is_playing',
	},
);

has default_mplayer_class => (
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
		pause      => 1,
		skip       => 1,
		is_playing => 1,
	}->{$method};
}

sub _build_mplayer
{
	my $self = shift;
	$self->construct_instance(
		use_package_optimistically($self->default_mplayer_class),
	);
}

sub _build_default_mplayer_class
{
	'SoundSwarm::MPlayer';
}

sub start_playing
{
	my $self = shift;
	my $mplayer = $self->mplayer; # force construction
	my $async   = Async->new(sub
	{
		while (1)
		{
			my $song = $self->next_song;
			last unless defined $song;
			$self->log("Next song: %s", $song);
			$self->play($song);
			$self->wait;
		}
	});
	confess $async->error if defined $async->error;
	$self->_set_queue_management_process($async);
}

before daemonize => sub
{
	my $self = shift;
	$self->start_playing;
};

1;

