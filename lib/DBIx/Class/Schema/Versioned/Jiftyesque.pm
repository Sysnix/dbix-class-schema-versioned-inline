package DBIx::Class::Schema::Versioned::Jiftyesque;

=head1 NAME

DBIx::Class::Schema::Versioned::Jiftyesque - since/until schema versioning for DBIx::Class in the style of L<Jifty>

=head1 VERSION

Version 0.001

=cut

our $VERSION = '0.001';

=head1 SYNOPSIS

 package MyApp::Schema;

 use base 'DBIx::Class::Schema::Versioned::Jiftyesque';

 our $VERSION = '0.002';

 __PACKAGE__->load_namespaces;

 ...

 package MyApp::Schema::Result::Foo;

 use base 'DBIx::Class::Core';

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

 ...

 package MyApp::Schema::Result::Bar;

 use base 'DBIx::Class::Core';

 __PACKAGE__->table('bars');

 __PACKAGE__->add_columns(
   "bars_id",
   { data_type => 'integer', is_auto_increment => 1, },
   "age",
   { data_type => "integer", is_nullable => 1 },
   "height",
   { data_type => "integer", is_nullable => 1, extra => { until => '0.003' } },
 );

 sub since { '0.002' }

 ...

 package MyApp::Schema::Upgrade;

 use base 'DBIx::Class::Schema::Versioned::Jiftyesque::Upgrade';
 use DBIx::Class::Schema::Versioned::Jiftyesque::Upgrade qw(since rename);

 since '0.003' => sub {
   rename class => 'Foo', to => 'Product', table => 'products';
   # do some other things like renaming primary key column
 }

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

    # add schema cersion
    push @schema_versions, $self->get_db_version, $self->schema_version;

    # add Upgrade versions
    my $upgradeclass = ref($self) . "::Upgrade";
    eval {
        eval "require $upgradeclass" or return;
        push @schema_versions, $upgradeclass->versions;
    };

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

        my $extra = $to_register->column_info($column)->{extra};

        my $since = $extra->{since};
        my $until = $extra->{until};

        if ( $since ) {
            push @schema_versions, $since;
            if ( version->parse( $since ) > $version ) {
                $to_register->remove_column($column);
            }
        }

        if ( $until ) {
            push @schema_versions, $until;
            if ( version->parse( $until ) < $version ) {
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
        print STDERR "until $to_register $until $version\n";
        push @schema_versions, $until;
        return if ( version->parse($until) < $version );
        print STDERR "======\n";
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
