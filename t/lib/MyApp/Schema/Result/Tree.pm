package MyApp::Schema::Result::Tree;

use strict;
use warnings;

use base qw(DBIx::Class::Core);

__PACKAGE__->load_components(qw/Schema::Versioned::Jiftyesque::Result/);

__PACKAGE__->table("trees");

__PACKAGE__->add_columns(
    "height",
    { data_type => "numeric", is_nullable => 1, size => [10, 2] },
    "age",
    { data_type => "integer", is_nullable => 1, extra => { since => '0.004' } },
    "branches",
    { data_type => "integer", is_nullable => 1, extra => { until => '0.003' } },
);

sub since { '0.002' };

sub schema {
    my $self = shift;
    return $self->result_source->schema;

}

1;
