package SoundSwarm::Syntax;

use Async ();
use Syntax::Collector -collect => q/
	use Carp 0 qw( confess );
	use Scalar::Util 0 qw( blessed );
	use MooX::Types::MooseLike::Base 0 qw( :all );
	use Module::Runtime 0 qw( use_module use_package_optimistically );
/;

1;
