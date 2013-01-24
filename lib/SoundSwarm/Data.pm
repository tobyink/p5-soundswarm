package SoundSwarm::Data;

use strict;
use warnings;
use File::Spec;
use SoundSwarm::Data::Track;
use re ();

use ORLite {
	file    => File::Spec->catfile($ENV{HOME}, qw/ .soundswarm data.sqlite /),
	create  => sub {
		my $dbh = shift;
		$dbh->do('CREATE TABLE track (filename TEXT PRIMARY KEY, title TEXT, artist TEXT, album TEXT)');
	},
};

1;
