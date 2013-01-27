package SoundSwarm::WWW::RPC;

use SoundSwarm::Syntax;
use Plack::Request;
use JSON qw( to_json from_json );
use Try::Tiny;

sub app
{
	my %clients = map { ;$_ => $_->new } qw(
		SoundSwarm::Client::Library
		SoundSwarm::Client::Queue
		SoundSwarm::Client::Player
	);
	
	return sub
	{
		my $env      = "Plack::Request"->new($_[0]);
		my $rpc      = from_json($env->content);
		my $method   = $rpc->{method};
		my $client   = $clients{ "SoundSwarm"->get_procedure_client($method) };
		
		my $response;
		try {
			my $result   = $client->$method(@{ $rpc->{params} || [] });
			$response = $env->new_response(200);
			$response->content_type("application/json");
			$response->body(to_json {
				result  => $result,
				error   => undef,
				id      => $rpc->{id},
			});
		}
		catch {
			my $e = shift;
			$response = $env->new_response(500);
			$response->content_type("application/json");
			$response->body(to_json {
				result  => undef,
				error   => $e,
				id      => $rpc->{id},
			});
		};
		
		$response->finalize;
	}
}

1;


