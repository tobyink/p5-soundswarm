package SoundSwarm::Role::Client::JSONRPC;

use SoundSwarm::Syntax;
use Moo::Role;
use JSON qw( to_json from_json );

requires 'send_line';

my $id = 0;

sub call
{
	my $self = shift;
	my ($method, @params) = @_;
	my $response = from_json(
		$self->send_line(
			to_json({
				method => $method,
				params => $params,
				id     => ++$id,
			})."\n"
		),
	);
	
	confess $response->{error}
		if exists $response->{error};
	
	confess "JSON-RPC id does not match!"
		if exists $response->{id} && $response->{id} != $id;
	
	return $response->{result};
}

1;

