package SoundSwarm::Role::Client::JSONRPC;

use SoundSwarm::Syntax;
use Moo::Role;
use JSON qw( to_json from_json );
use Sub::Install qw( install_sub );
use Sub::Name qw( subname );

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
				params => \@params,
				id     => ++$id,
			})."\n"
		),
	);
	
	confess $response->{error}
		if defined $response->{error};
	
	confess "JSON-RPC id does not match!"
		if defined $response->{id} && $response->{id} != $id;
	
	return $response->{result};
}

sub __proxy
{
	my $package = shift;
	for my $method (@_)
	{
		install_sub {
			into   => $package,
			as     => $method,
			code   => subname "$package\::$method", sub { my $self = shift; $self->call($method => @_); },
		};
	}
}

1;

