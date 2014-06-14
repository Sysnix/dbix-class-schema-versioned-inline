#
# Foo class
#
package TestVersion::Foo;
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
    "bars_id",
    { data_type => 'integer', is_foreign_key => 1, is_nullable => 0, extra => { since => '0.002' } },
);

__PACKAGE__->set_primary_key('foos_id');

__PACKAGE__->has_one(
    'Bar',
    'TestVersion::Bar',
    'bars_id',
    { extra => { since => '0.002' }},
);

__PACKAGE__->resultset_attributes({ extra => { until => '0.002' }});

#
# Bar class
#
package TestVersion::Bar;
use base 'DBIx::Class::Core';
use strict;
use warnings;

__PACKAGE__->table('bars');

__PACKAGE__->add_columns(
    "bars_id",
    { data_type => 'integer', is_auto_increment => 1, },
    "age",
    { data_type => "integer", is_nullable => 1 },
    "height",
    { data_type => "integer", is_nullable => 1, extra => { since => '0.003' } },
    "weight",
    { data_type => "integer", is_nullable => 1, extra => { until => '0.3' } },
);

__PACKAGE__->set_primary_key('bars_id');

__PACKAGE__->belongs_to(
    'Foo',
    'TestVersion::Foo',
    'bars_id',
    { extra => { until => '0.002' }},
);

__PACKAGE__->resultset_attributes({ extra => { since => '0.002' }});

#
# Schema
#
package TestVersion::Schema;
use base 'DBIx::Class::Schema::Versioned::Jiftyesque';
use strict;
use warnings;

our $VERSION = '0.4';

__PACKAGE__->register_class( 'Foo', 'TestVersion::Foo' );
__PACKAGE__->register_class( 'Bar', 'TestVersion::Bar' );

1;
