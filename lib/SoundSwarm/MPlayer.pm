package SoundSwarm::MPlayer;

use SoundSwarm::Syntax;
use Moo;
use File::Which 'which';
use File::Spec;
use POSIX 'mkfifo';

has mplayer_path => (
	is      => 'lazy',
	isa     => Str,
	default => sub { which('mplayer') },
);

has mplayer_pid => (
	is      => 'rwp',
	isa     => Int,
	clearer => '_clear_mplayer_pid',
	predicate => 'has_mplayer_pid',
);

has fifo => (
	is      => 'ro',
	isa     => Str,
	default => sub {
		my $fifo = "File::Spec"->catfile("File::Spec"->tmpdir, 'soundswarm-mplayer.fifo');
		1 while unlink $fifo;
		mkfifo($fifo, 0700) or confess "could not make FIFO $fifo: $!";
		return $fifo;
	},
);

sub play
{
	my $self = shift;
	my ($filename) = @_;
	
	if (my $pid = fork) {
		$self->_set_mplayer_pid($pid);
		return $self;
	}
	
	else {			
		exec(
			$self->mplayer_path,
			'-slave'        => (),
			'-input'        => join("=", file => $self->fifo),
			'-really-quiet' => (),
			$filename,
		) or confess "Unable to exec mplayer: $!";
	}
}

sub is_playing
{
	my $self = shift;
	$self->has_mplayer_pid and kill(0, $self->mplayer_pid);
}

sub _signal_mplayer
{
	my $self = shift;
	open my $fifo, '>', $self->fifo or confess "Unable to open FIFO: $!";
	print $fifo "$_\n" for @_;
	close $fifo or confess "Unable to close FIFO: $!";
	return { status => '202' };
}

sub pause
{
	my $self = shift;
	$self->_signal_mplayer('pause');
}

sub stop
{
	my $self = shift;
	$self->_signal_mplayer('stop');
}

sub wait
{
	my $self = shift;
	return unless $self->is_playing;
	waitpid($self->mplayer_pid, 0);
}

1;
