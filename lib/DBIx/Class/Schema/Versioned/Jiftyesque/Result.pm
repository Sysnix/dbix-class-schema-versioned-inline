package DBIx::Class::Schema::Versioned::Jiftyesque::Result;

=head1 NAME

DBIx::Class::Schema::Versioned::Jiftyesque::Result

=cut

use strict;
use warnings;

use base qw(DBIx::Class::Core);

use version 0.77;

use namespace::clean;

sub __UNUSED_register_column {
    my ( $self, $column, $info, @rest ) = @_;

    # this SUCKS and is only good if we are something like:
    #   MyApp::Schema::Result::Foo
    # and also the schema is:
    #   MyApp::Schema
    ( my $schema_class = $self ) =~ s/::Result::.*//;

    # get the schema version cleanly (as per schema_version in DBICS::Versioned)
    my $schema_version;
    {
        no strict 'refs';
        $schema_version = ${"${schema_class}::VERSION"};
    }

    if ( $info->{extra}->{since}
        && version->parse( $info->{extra}->{since} ) >
        version->parse($schema_version) )
    {

        # we don't want this column yet

        $self->remove_column($column);
        return;
    }

    if ( $info->{extra}->{until}
        && version->parse( $info->{extra}->{until} ) <
        version->parse($schema_version) )
    {

        # we don't want this column anymore

        $self->remove_column($column);
        return;
    }

    # register this column
    $self->next::method( $column, $info, @rest );
}

1;
