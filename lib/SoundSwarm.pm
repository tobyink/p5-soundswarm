package SoundSwarm;

use strict;
use warnings;

use constant {
	PLAYER_PORT  => $ENV{SOUNDSWARM_PLAYER_PORT}  // 4242,
	QUEUE_PORT   => $ENV{SOUNDSWARM_QUEUE_PORT}   // 4243,
	LIBRARY_PORT => $ENV{SOUNDSWARM_LIBRARY_PORT} // 4244,
};

BEGIN {
	$SoundSwarm::AUTHORITY = 'cpan:TOBYINK';
	$SoundSwarm::VERSION   = '0.001';
}

my $rpc_map = +{};

sub register_procedure_client
{
	my ($class, $procedure, $client) = @_;
	if (exists $rpc_map->{$procedure} and $rpc_map->{$procedure} ne $client)
	{
		require Carp;
		Carp::confess("conflict for procedure '$procedure': $client versus $rpc_map->{$procedure}");
	}
	$rpc_map->{$procedure} = $client;
}

sub get_procedure_client
{
	my ($class, $procedure) = @_;
	$rpc_map->{$procedure};
}

1;

__END__

=head1 NAME

SoundSwarm - swarm of media playing daemons

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=SoundSwarm>.

=head1 SEE ALSO

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2013 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

