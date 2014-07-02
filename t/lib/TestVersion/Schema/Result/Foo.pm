package TestVersion::Schema::Result::Foo;
use base 'DBIx::Class::Core';
use strict;
use warnings;

__PACKAGE__->table('foos');

__PACKAGE__->add_columns(
    "foos_id" => { data_type => 'integer', is_auto_increment => 1 },
    "age"     => {
        data_type   => "integer",
        is_nullable => 1,
        versioned   => { since => '0.002' }
    },
    "height" => {
        data_type   => "integer",
        is_nullable => 1,
        versioned   => { until => '0.002' }
    },
    "width" => {
        data_type   => "integer",
        is_nullable => 1,
        versioned   => { since => '0.002', renamed_from => 'height' }
    },
    "bars_id" => {
        data_type      => 'integer',
        is_foreign_key => 1,
        is_nullable    => 0,
        versioned      => { since => '0.002' }
    },
);

__PACKAGE__->set_primary_key('foos_id');

__PACKAGE__->belongs_to(
    'bar', 'TestVersion::Schema::Result::Bar',
    'bars_id', { versioned => { since => '0.002' } },
);

__PACKAGE__->resultset_attributes( { versioned => { until => '0.003' } } );

1;
