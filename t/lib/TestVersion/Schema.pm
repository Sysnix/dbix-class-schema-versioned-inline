package TestVersion::Schema;
use base 'DBIx::Class::Schema::Versioned::Inline';
use strict;
use warnings;

our $VERSION = '0.000001';

__PACKAGE__->load_namespaces();

1;
