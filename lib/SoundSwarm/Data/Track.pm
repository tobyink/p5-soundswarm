package SoundSwarm::Data::Track;

use SoundSwarm::Syntax;
use Music::Tag (traditional => 1);
use Path::Class;

require SoundSwarm::Data;

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
	return grep $filter->(), @results;
}

sub TO_JSON
{
	return +{%{+shift}};
}

sub from_file
{
	my $class = shift;
	my ($file) = @_;
	warn "Indexing $file\n";
	my $info = "Music::Tag"->new("$file", { quiet => 1 });
	$info->get_tag;
	return $class->new(
		filename => "$file",
		title    => $info->title,
		artist   => $info->artist,
		album    => $info->album,
	);
}

sub from_dir
{
	my $class = shift;
	my $dir   = "Path::Class::Dir"->new(@_);
	my @return;
	$dir->recurse(callback => sub
	{
		my $file = shift;
		return if $file->is_dir;
		return unless "$file" =~ /\.(ogg|mp3|mp4|m4a|3gp|flac)$/i;
		push @return, $class->from_file($file);
	});
	return @return;
}

1;
