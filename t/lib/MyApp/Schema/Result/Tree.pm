package MyApp::Schema::Result::Tree;

use strict;
use warnings;

use base qw(DBIx::Class::Core);

__PACKAGE__->table("trees");

__PACKAGE__->add_columns(
    "height",
    { until => '0.3', data_type => "numeric", is_nullable => 1, size => [10, 2] },
    "age",
    { since => '0.004', data_type => "integer", is_nullable => 1 },
    "branches",
    { until => '0.003', data_type => "integer", is_nullable => 1 },
);

sub since { '0.002' };

1;
