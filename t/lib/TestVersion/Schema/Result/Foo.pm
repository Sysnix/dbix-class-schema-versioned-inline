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
    { data_type => "integer", is_nullable => 1, extra => { until => '0.001' } },
    "width",
    { data_type => "integer", is_nullable => 1, extra => { since => '0.002', renamed_from => 'height' } },
    "bars_id",
    { data_type => 'integer', is_foreign_key => 1, is_nullable => 0, extra => { since => '0.002' } },
);

__PACKAGE__->set_primary_key('foos_id');

__PACKAGE__->belongs_to(
    'bar',
    'TestVersion::Schema::Result::Bar',
    'bars_id',
    { extra => { since => '0.002' }},
);

__PACKAGE__->resultset_attributes({ extra => { until => '0.002' }});

1;
