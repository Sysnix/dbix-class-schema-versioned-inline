package MyApp::Schema;

our $VERSION = 0.002;

use base qw/DBIx::Class::Schema::Versioned::Jiftyesque/;

__PACKAGE__->load_namespaces;

1;
