package SoundSwarm::Role::Daemon::JSONRPC;

use SoundSwarm::Syntax;
use Moo::Role;
use JSON qw( to_json from_json );

requires 'is_valid_method';

sub handle_line
{
	my $self = shift;
	my ($line) = @_;
	my $in = eval { from_json($line) }
		or return $self->_jsonrpc_error("Invalid JSON.");
	
	my $method = $in->{method}
		or return $self->_jsonrpc_error("Invalid JSON-RPC.", $in->{id});
	
	if ($method eq 'quit' and $self->DOES('SoundSwarm::Role::Daemon'))
	{
		return (
			$self->_jsonrpc_result({ status => 'OK' }, $in->{id}),
			SoundSwarm::Role::Daemon->END_CLIENT,
		);
	}
	
	$self->can($method) && $self->is_valid_method($method)
		or return $self->_jsonrpc_error("No such method '$method'.", $in->{id});
	
	my @params = @{ $in->{params} || [] };
	my $result = $self->$method(@params);
	
	return $self->_jsonrpc_result($result, $in->{id});
}

sub _jsonrpc_result
{
	my $self = shift;
	my ($result, $id) = @_;
	to_json({
		id      => $id || 0,
		error   => undef,
		result  => $result,
	})."\n";
}

sub _jsonrpc_error
{
	my $self = shift;
	my ($error, $id) = @_;
	
	my $E = to_json({
		id      => $id,
		error   => $error,
		result  => undef,
	})."\n";
	
	return ($E, SoundSwarm::Role::Daemon->END_CLIENT)
		if $self->DOES('SoundSwarm::Role::Daemon');
	
	return $E;
}

1;
