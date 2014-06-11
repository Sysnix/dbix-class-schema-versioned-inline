#
# Foo class valid from any version until 0.002
# column age in 0.002 only
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
    { since => '0.002', data_type => "integer", is_nullable => 1 },
    "height",
    { data_type => "integer", is_nullable => 1 },
);

sub until { '0.002' };

#
# Bar class valid from 0.002 onwards
# column age until 0.004
# column height from 0.003 onwards
# column weight until 0.3
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
    { until => '0.004', data_type => "integer", is_nullable => 1 },
    "height",
    { since => '0.003', data_type => "integer", is_nullable => 1 },
    "weight",
    { until => '0.3', data_type => "integer", is_nullable => 1 },
);

sub since { '0.002' };

#
# Schema
#
package TestVersion::Schema;
use base 'DBIx::Class::Schema::Versioned::Jiftyesque';
use strict;
use warnings;

our $VERSION = '0.001';

__PACKAGE__->register_class('Foo', 'TestVersion::Foo');
__PACKAGE__->register_class('Bar', 'TestVersion::Bar');

1;
