package SoundSwarm::Role::Daemon;

use SoundSwarm::Syntax;
use MooX::Role;
use AnyEvent;
use AnyEvent::Socket;

use constant {
	END_CLIENT  => \(1),
	END_DAEMON  => \(2),
};

requires 'log';
requires 'host', 'port';
requires 'handle_line';

sub daemonize
{
	my $self = shift;
	$self->log("Listening on %s:%d", $self->host, $self->port);
	
	my $cv = AnyEvent->condvar;
	
	tcp_server $self->host, $self->port, sub
	{
		my $client = shift;
		$self->log("Connection from %s:%d", @_);
		
		LINE: while (defined(my $line = <$client>))
		{
			warn "SERVER RECV LINE: $line";
			for my $response ($self->handle_line($line))
			{
				warn "SERVER SEND LINE: $response";
				if (ref $response and $response == END_CLIENT) {
					last LINE;
				}
				elsif (ref $response and $response == END_DAEMON) {
					$cv->send;
					last LINE;
				}
				syswrite $client, $response;
			}
		}
		
		$self->log("Connection from %s:%d closed!", @_);
	};
	
	$cv->recv;
}

1;

