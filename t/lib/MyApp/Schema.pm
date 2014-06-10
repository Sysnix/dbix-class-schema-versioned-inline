package MyApp::Schema;

our $VERSION = 0.001;

use base qw/DBIx::Class::Schema::Versioned::Jiftyesque/;

use Data::Dumper;

__PACKAGE__->load_namespaces;

#__PACKAGE__->load_components(qw/Schema::Versioned::Jiftyesque/);

1;
