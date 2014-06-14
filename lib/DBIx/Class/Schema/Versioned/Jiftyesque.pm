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
   "bars_id",
   { data_type => 'integer', is_foreign_key => 1, is_nullable => 0, extra => { since => '0.002' } },
 );

 __PACKAGE__->set_primary_key('foos_id');

 __PACKAGE__->has_one(
   'Bar',
   'TestVersion::Schema::Result::Bar',
   'bars_id',
   { extra => { since => '0.002' }},
 );

 __PACKAGE__->resultset_attributes({ extra => { until => '0.002' }});

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
   "weight",
   { data_type => "integer", is_nullable => 1, extra => { until => '0.3' } },
 );

 __PACKAGE__->set_primary_key('bars_id');

 __PACKAGE__->belongs_to(
   'Foo',
   'TestVersion::Schema::Result::Foo',
   'bars_id',
   { extra => { until => '0.002' }},
 );

 __PACKAGE__->resultset_attributes({ extra => { since => '0.002' }});

 ...

 package MyApp::Schema::Upgrade;

 use base 'DBIx::Class::Schema::Versioned::Jiftyesque::Upgrade';
 use DBIx::Class::Schema::Versioned::Jiftyesque::Upgrade qw(since rename);

 since '0.003' => sub {
   rename class => 'Foo', to => 'Product', table => 'products';
   # do some other things like renaming primary key column
 }

=head1 DESCRIPTION

This module extends L<DBIx::Class::Schema::Versioned> using simple 'since' and 'until' markers within result classes to specify the schema version at which classes and columns were introduced or removed. Column since/until definitions are included as part of 'extra' info in add_column(s). 

=head2 since

When a class is added to a schema at a specific schema version version then a 'since' attribute must be added to the class which returns the version at which the class was added. For example:

 __PACKAGE__->resultset_attributes({ extra => { since => '0.002' }});

It is not necessary to add this to the initial version of a class since any class without this atribute is assumed to have existed for ever.

Using 'since' in a column or relationship definition denotes when the column/relation was added OR when changes were last made to it.

=head2 until

When used as a class attribute this should be the final schema version at which the class is to be used. The underlying database table will be removed when the schema is upgraded to a higher version. Example definition:

 __PACKAGE__->resultset_attributes({ extra => { since => '0.3' }});

Using 'until' in a column or relationship definition will cause removal of the column/relation from the table when the schema is upgraded past this version.

=cut

use warnings;
use strict;

use base 'DBIx::Class::Schema::Versioned';

use Carp;
use Data::Dumper::Concise;
use version 0.77;

our @schema_versions;

=head1 METHODS

Many methods are inherited or overloaded from L<DBIx::Class::Schema::Versioned>.

=head2 connection

Overloaded method. This checks the DBIC schema version against the DB version and warns if they are not the same or if the DB is unversioned.

To avoid the checks on connect, set the environment var DBIC_NO_VERSION_CHECK or alternatively you can set the ignore_version attr in the forth argument like so:

  my $schema = MyApp::Schema->connect(
    $dsn,
    $user,
    $password,
    { ignore_version => 1 },
  );

=cut

sub connection {
  my $self = shift;
  $self->next::method(@_);
  $self->_on_connect();
  return $self;
}

sub _on_connect {
    my $self = shift;

    my $conn_info = $self->storage->connect_info;
    $self->{vschema} = DBIx::Class::Version->connect(@$conn_info);
    my $conn_attrs = $self->{vschema}->storage->_dbic_connect_attributes || {};

    my $vtable = $self->{vschema}->resultset('Table');

    my $version = $self->get_db_version();

    unless ( $version ) {
        # TODO: checks for unversioned
        # - do we throw exception?
        # - do we install automatically?
        # - can we be passed some method or connect arg?
        # for now just set $pversion to schema_version
        $version = $self->schema_version;
    }

    $self->_cleanup_versions( $version );

    return 1;
}

=head2 deploy

Inherited method. Same as L<DBIx::Class::Schema/deploy> but also calls C<install>.

=head2 install

Inherited method. Call this to initialise a previously unversioned database.

=head2 ordered_schema_versions

Overloaded method. Returns an ordered list of schema versions. This is then used to produce a set of steps to upgrade through to achieve the required schema version.

=cut

sub ordered_schema_versions {
    my $self = shift;

    # add schema and database versions to list
    push @schema_versions, $self->get_db_version, $self->schema_version;

    # add Upgrade versions
    my $upgradeclass = ref($self) . "::Upgrade";
    eval {
        eval "require $upgradeclass" or return;
        push @schema_versions, $upgradeclass->versions;
    };

    return sort { version->parse($a) <=> version->parse($b) } do {
        my %seen;
        grep { !$seen{$_}++ } @schema_versions;
    };
}

=head2 _cleanup_versions

Used to weed out classes and columns that are not appropriate for our current database version based on since/until values. Collects available versions at the same time.

=cut

sub _cleanup_versions {
    my ( $self, $_version ) = @_;

    my $pversion = version->parse( $_version );

    #warn "DB VERSION " . $self->get_db_version;

    foreach my $source_name ( $self->sources ) {

        #warn "SOURCE NAME $source_name";

        my $source = $self->source($source_name);

        # check columns before deciding on class-level since/until to make sure
        # we don't miss any versions

        foreach my $column ( $source->columns ) {

            my $extra = $source->column_info($column)->{extra};

            my $since = $extra->{since};
            my $until = $extra->{until};

            my $name = "$source_name column $column";
            my $sub  = sub {
                my $source = shift;
                $source->remove_column($column);
            };
            $self->_since_until( $pversion, $extra->{since}, $extra->{until}, $name, $sub, $source );
        }

        # now check relations

        foreach my $relation_name ( $source->relationships ) {

            my $attrs = $source->relationship_info( $relation_name )->{attrs};

            next unless defined $attrs;

            my $extra = $attrs->{extra};

            next unless defined $extra;

            my $since = $extra->{since};
            my $until = $extra->{until};

            my $name = "$source_name relationship $relation_name";
            my $sub  = sub {
                my $source = shift;
                my %rels = %{ $source->_relationships };
                delete $rels{$relation_name};
                $source->_relationships(\%rels);
            };
            $self->_since_until( $pversion, $extra->{since}, $extra->{until}, $name, $sub, $source );
        }

        # now check class-level since/until
 
        my ( $since, $until );

        my $extra = $source->resultset_attributes->{extra};

        if ( defined $extra ) {
            $since = $extra->{since} if defined $extra->{since};
            $until = $extra->{until} if defined $extra->{until};
        }

        my $name = $source_name;
        my $sub  = sub {
            my $class = shift;
            $class->unregister_source($source_name);
        };
        $self->_since_until( $pversion, $extra->{since}, $extra->{until}, $name, $sub, $self );
    }
}

sub _since_until {
    my ( $self, $pversion, $since, $until, $name, $sub, $thing ) = @_;

    if ( $since && $until && ( version->parse($since) > version->parse($until) ) ) {
        $self->throw_exception("$name has since greater than until");
    }

    push( @schema_versions, $since ) if $since;
    push( @schema_versions, $until ) if $until;

    # until is absolute so parse before since
    if ( $until && $pversion > version->parse($until) ) {
        $sub->($thing);
    }
    if ( $since && $pversion < version->parse($since) ) {
        $sub->($thing);
    }
}

=head2 upgrade

Inherited method. Call this to attempt to upgrade your database from the version it is at to the version this DBIC schema is at. If they are the same it does nothing.

=head2 upgrade_single_step

=over 4
 
=item Arguments: db_version - the version currently within the db
 
=item Arguments: target_version - the version to upgrade to

=back

Overloaded method. Call this to attempt to upgrade your database from the I<db_version> to the I<target_version>. If they are the same it does nothing.

All upgrade operations within this step are performed inside a single transaction so either all succeed or all fail. If successful the dbix_class_schema_versions table is updated with the I<target_version>.

This method may be called repeatedly by the L</upgrade> method to upgrade through a series of updates.

=cut

sub upgrade_single_step {
    my ( $self, $db_version, $target_version ) = @_;

    # db and schema at same version. do nothing
    if ( $db_version eq $target_version ) {
        carp 'Upgrade not necessary';
        return;
    }
    carp "attempting upgrade from $db_version to $target_version";
}

=head1 CAVEATS

Please anticipate API changes in this early state of development.

=head1 AUTHOR

Peter Mottram (SysPete), "peter@sysnix.com"

=head1 BUGS

LOTS of bugs and missing features right now.

NOTE: upgrades are NOT yet implemented.

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

Thanks to Best Practical Solutions for the L<Jifty> framework and L<Jifty::DBI> which inspired this distribution. Thanks also to Matt S. Trout and all of the L<DBIx::Class> developers for an excellent distribution.

=head1 LICENSE AND COPYRIGHT

Copyright 2014 Peter Mottram (SysPete).

This program is free software; you can redistribute it and/or modify it under the terms of either: the GNU General Public License as published by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
