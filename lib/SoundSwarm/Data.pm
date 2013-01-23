package SoundSwarm::Data;

use SoundSwarm::Syntax;
use File::Spec;
use re ();

use ORLite {
	file    => File::Spec->catfile($ENV{HOME}, qw/ .soundswarm data.sqlite /),
	create  => sub {
		my $dbh = shift;
		$dbh->do('CREATE TABLE track (filename TEXT PRIMARY KEY, title TEXT, artist TEXT, album TEXT)');
	},
};

{
	package SoundSwarm::DataSearch;
	
	use Role::Tiny;
	requires 'select';
	
	sub search
	{
		my $class = shift;
		my (%search) = @_;
		my $filter;
		my (@terms, @bind);
		
		for my $key (keys %search)
		{
			my @vals = ref $search{$key} eq 'ARRAY'
				? @{$search{$key}}
				:   $search{$key}
			;
			
			for my $val (@vals)
			{
				if (ref $val eq 'Regexp')
				{
					my $orig = $filter || sub { 1 };
					$filter = sub { $_->{$key} =~ /$val/ and $orig->() };
					for my $chunk (grep length, re::regmust $val)
					{
						push @terms, "$key LIKE ?";
						push @bind, "\%$chunk\%";
					}
				}
				elsif (ref $val eq 'CODE')
				{
					my $orig = $filter || sub { 1 };
					$filter = sub { $val->() and $orig->() };
				}
				elsif (ref $val eq 'SCALAR')
				{
					unshift @terms, "$key = ?";
					unshift @bind, $$val;
				}
				else
				{
					push @terms, "$key LIKE ?";
					push @bind, "\%$val\%";
				}
			}
		}
		
		my $where   = join(" AND ", @terms);
		my @results = $class->select("WHERE $where", @bind);
		
		return @results unless $filter;
		return grep { $filter->() } @results;
	}
}

"Role::Tiny"->apply_roles_to_package(
	"SoundSwarm::Data::Track",
	"SoundSwarm::DataSearch",
);

1;
