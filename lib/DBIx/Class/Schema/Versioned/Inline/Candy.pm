package DBIx::Class::Schema::Versioned::Inline::Candy;
use warnings;
use strict;

use Data::Dumper::Concise;

=head1 NAME

DBIx::Class::Schema::Versioned::Inline::Candy - add Candy to result classes

=cut

use DBIx::Class::Candy::Exports;

export_methods [qw(
    renamed_from
    since
    till
)];

sub _set_attr {
    my ( $self, $key, $value ) = @_;
    my $attrs = $self->resultset_attributes;
    $attrs->{versioned}->{$key} = $value;
    $self->resultset_attributes( $attrs );
}

sub renamed_from {
    shift->_set_attr( renamed_from => shift );
}

sub since {
    shift->_set_attr( since => shift );
}

sub till {
    shift->_set_attr( until => shift );
}

1;
