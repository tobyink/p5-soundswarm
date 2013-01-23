package SoundSwarm::Role::Daemon;

use SoundSwarm::Syntax;
use MooX::Role;

use constant {
	END_CLIENT  => \(1),
	END_DAEMON  => \(2),
};

requires 'log';
requires 'host', 'port';
requires 'handle_line';

has socket => (
	is      => 'lazy',
	isa     => InstanceOf[ 'IO::Socket' ],
);

sub _build_socket
{
	require IO::Socket::INET;
	my $self = shift;
	my $sock = 'IO::Socket::INET'->new(
		Listen     => 5,
		LocalAddr  => $self->host,
		LocalPort  => $self->port,
		Proto      => 'tcp',
	) or confess "Cannot open socket: $!";
	return $sock;
}

sub daemonize
{
	my $self = shift;
	my $sock = $self->socket;
	
	$self->log("Listening on %s:%d", $sock->sockhost, $sock->sockport);
	
	CLIENT: while (1)
	{
		my $client = $sock->accept;
		$self->log("Connection from %s:%d", $client->peerhost, $client->peerport);
		
		LINE: while (defined(my $line = <$client>))
		{
			for my $response ($self->handle_line($line))
			{
				if (ref $response and $response == END_CLIENT) {
					$client->close;
					last LINE;
				}
				elsif (ref $response and $response == END_DAEMON) {
					$client->close;
					$sock->close;
					last CLIENT;
				}
				print {$client} $response;
			}
		}
	}
}

1;

