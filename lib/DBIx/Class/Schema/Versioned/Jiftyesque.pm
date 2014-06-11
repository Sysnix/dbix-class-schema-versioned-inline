package DBIx::Class::Schema::Versioned::Jiftyesque;

=head1 NAME

DBIx::Class::Schema::Versioned::Jiftyesque

=head1 VERSION

Version 0.001

=cut

our $VERSION = '0.001';

=head1 SYNOPSIS

Schema class should inherit from DBIx::Class::Schema::Versioned::Jiftyesque:

  package MyApp::Schema;

  use base 'DBIx::Class::Schema::Versioned::Jiftyesque';

  __PACKAGE__->load_namespaces;

Result classes can define class-level since/until with simple sub and column-level by including since/until in column info:

  package MyApp::Schema::Result::Tree;

  __PACKAGE__->table("trees");

  __PACKAGE__->add_columns(
      "height",
      { data_type => "numeric", size => [10, 2] },
      "age",
      { since => '0.004', data_type => "integer" },
      "branches",
      { until => '0.003', data_type => "integer" },
      ...
  );

  sub since { '0.002' };
  ...

=cut

use warnings;
use strict;

use base 'DBIx::Class::Schema::Versioned';

use Data::Dumper;
use version 0.77;

our @schema_versions;

=head1 METHODS

=head2 ordered_schema_versions

Return an ordered list of schema versions. This is then used to produce a set of steps to upgrade through to achieve the required schema version.

=cut

sub ordered_schema_versions {
    my $self = shift;

    push @schema_versions, $self->get_db_version, $self->schema_version;

    return sort { version->parse->parse($a) <=> version->parse($b) } do {
        my %seen;
        grep { !$seen{$_}++ } @schema_versions;
    };
}

=head2 register_class

Overload register_class to weed out classes and columns that are not appropriate for our current schema version based on since/until values.

=cut

sub register_class {
    my ( $self, $source_name, $to_register ) = @_;

    my $version = version->parse( $self->schema_version );

    # check columns before deciding on class-level since/until to make sure
    # we don't miss any versions

    foreach my $column ( $to_register->columns ) {

        my $info = $to_register->column_info($column);

        if ( $info->{since} ) {
            push @schema_versions, $info->{since};
            if ( version->parse( $info->{since} ) > $version ) {
                $to_register->remove_column($column);
            }
        }

        if ( $info->{until} ) {
            push @schema_versions, $info->{until};
            if ( version->parse( $info->{until} ) < $version ) {
                $to_register->remove_column($column);
            }
        }
    }

    # now check class-level since/until

    if ( $to_register->can("since") ) {
        my $since = $to_register->since;
        push @schema_versions, $since;
        return if ( version->parse($since) > $version );
    }

    if ( $to_register->can("until") ) {
        my $until = $to_register->until;
        push @schema_versions, $until;
        return if ( version->parse($until) < $version );
    }

    $self->next::method( $source_name, $to_register );
}

=head1 CAVEATS

Please anticipate API changes in this early state of development.

=head1 AUTHOR

Peter Mottram (SysPete), "peter@sysnix.com"

=head1 BUGS

LOTS at of bugs and missing features right now.

Please report any bugs or feature requests via the project's GitHub issue tracker:

L<https://github.com/Sysnix/dbix-class-schema-versioned-jiftyesque/issues>

I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc DBIx::Class::Schema::Versioned::Jiftyesque

You can also look for information at:

=over 4

=item * GitHub repository

L<https://github.com/Sysnix/dbix-class-schema-versioned-jiftyesque>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/DBIx-Class-Schema-Versioned-Jiftyesque>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/DBIx-Class-Schema-Versioned-Jiftyesque>

=item * Search CPAN

L<http://search.cpan.org/dist/DBIx-Class-Schema-Versioned-Jiftyesque/>

=back

=head1 ACKNOWLEDGEMENTS

Thanks to Best Practical Solutions for the L<Jifty> framework and L<Jifty::DBI> which inspired this distribution. 

=head1 LICENSE AND COPYRIGHT

Copyright 2014 Peter Mottram (SysPete).

This program is free software; you can redistribute it and/or modify it under the terms of either: the GNU General Public License as published by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
