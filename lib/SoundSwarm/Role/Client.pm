package SoundSwarm::Role::Client;

use SoundSwarm::Syntax;
use Moo::Role;

requires 'log';
requires 'host', 'port';

sub socket
{
	require IO::Socket::INET;
	my $self = shift;
	my $sock = 'IO::Socket::INET'->new(
		PeerAddr   => $self->host,
		PeerPort   => $self->port,
		Proto      => 'tcp',
	) or confess "Cannot open socket: $!";
	return $sock;
}

sub send_line
{
	my $self = shift;
	my ($line) = @_;
	
	my $sock = $self->socket;
	$self->log("Connected to %s:%d", $sock->sockhost, $sock->sockport);
	
	print $sock $line;
	my $response = <$sock>;
	$sock->close;
	return $response;
}

1;
