package SoundSwarm::Syntax;

use SoundSwarm;  # defines constants
use Syntax::Collector -collect => q/
	use strict 0;
	use warnings 0;
	no warnings 0 qw( numeric void uninitialized once );
	use Carp 0 qw( confess );
	use Scalar::Util 0 qw( blessed );
	use MooX::Types::MooseLike::Base 0 qw( :all );
	use Module::Runtime 0 qw( use_module use_package_optimistically );
/;

1;
