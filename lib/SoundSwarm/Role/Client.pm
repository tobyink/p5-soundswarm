package SoundSwarm::Role::Client;

use SoundSwarm::Syntax;
use Moo::Role;

### TODO - use AnyEvent::Socket;

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
	
	warn "CLIENT SEND LINE: $line";
	
	my $sock = $self->socket;
	$self->log("Connected to %s:%d", $sock->peerhost, $sock->peerport);
	
	print $sock $line;
	my $response = <$sock>;
	$sock->close;
	warn "CLIENT RECV LINE: $response";
	return $response;
}

1;
