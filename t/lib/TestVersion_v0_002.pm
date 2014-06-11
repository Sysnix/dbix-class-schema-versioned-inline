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
);

sub until { '0.002' }

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

sub since { '0.002' }

#
# Schema
#
package TestVersion::Schema;
use base 'DBIx::Class::Schema::Versioned::Jiftyesque';
use strict;
use warnings;

our $VERSION = '0.002';

__PACKAGE__->register_class( 'Foo', 'TestVersion::Foo' );
__PACKAGE__->register_class( 'Bar', 'TestVersion::Bar' );

1;
