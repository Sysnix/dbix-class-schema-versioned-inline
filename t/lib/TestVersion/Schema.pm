package TestVersion::Schema;
use base 'DBIx::Class::Schema::Versioned::Jiftyesque';
use strict;
use warnings;

our $VERSION = '0.001';

__PACKAGE__->load_namespaces;

1;
