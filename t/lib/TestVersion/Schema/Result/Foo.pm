package TestVersion::Schema::Result::Foo;
use base 'DBIx::Class::Core';
use strict;
use warnings;

__PACKAGE__->table('foos');

__PACKAGE__->add_columns(
    "foos_id",
    { data_type => 'integer', is_auto_increment => 1 },
    "age",
    { data_type => "integer", is_nullable => 1, extra => { since => '0.002' } },
    "height",
    { data_type => "integer", is_nullable => 1 },
);

sub until { '0.002' }

1;
