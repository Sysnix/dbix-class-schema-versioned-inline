# NAME

DBIx::Class::Schema::Versioned::Inline - Defined multiple schema versions within resultset classes

# VERSION

Version 0.203

# SUMMARY

Schema versioning for DBIx::Class with version information embedded
inline in the schema definition.

See ["VERSION NUMBERS"](#version-numbers) below for important information regarding schema
version numbering.

# SYNOPSIS

```perl
package MyApp::Schema;

use parent 'DBIx::Class::Schema';

__PACKAGE__->load_components('Schema::Versioned::Inline');

our $FIRST_VERSION = '0.001';
our $VERSION = '0.002';

__PACKAGE__->load_namespaces;

...

package MyApp::Schema::Result::Bar;

use base 'DBIx::Class::Core';

__PACKAGE__->table('bars');

__PACKAGE__->add_columns(
   "bars_id" => {
       data_type => 'integer', is_auto_increment => 1
   },
   "age" => {
       data_type => "integer", is_nullable => 1
   },
   "height" => {
     data_type => "integer", is_nullable => 1,
     versioned => { since => '0.003' }
   },
   "weight" => {
     data_type => "integer", is_nullable => 1,
     versioned => { until => '0.3' }
   },
);

__PACKAGE__->set_primary_key('bars_id');

__PACKAGE__->has_many(
   'foos', 'TestVersion::Schema::Result::Foo',
   'foos_id', { versioned => { until => '0.003' } },
);

__PACKAGE__->resultset_attributes( { versioned => { since => '0.002' } } );

...

package MyApp::Schema::Result::Foo;

use base 'DBIx::Class::Core';

__PACKAGE__->table('foos');

__PACKAGE__->add_columns(
   "foos_id" => {
       data_type => 'integer', is_auto_increment => 1
   },
   "age" => {
       data_type => "integer", is_nullable => 1,
       versioned => { since => '0.002' }
   },
   "height" => {
       data_type => "integer", is_nullable => 1,
       versioned => { until => '0.002' }
   },
   "width" => {
       data_type => "integer", is_nullable => 1,
       versioned => {
           since   => '0.002', renamed_from => 'height',
           changes => {
               '0.0021' => { is_nullable => 0, default_value => 0 }
           },
       }
   },
   "bars_id" => {
       data_type => 'integer', is_foreign_key => 1, is_nullable => 0,
       versioned => { since => '0.002' }
   },
);

__PACKAGE__->set_primary_key('foos_id');

__PACKAGE__->belongs_to(
   'bar',
   'TestVersion::Schema::Result::Bar',
   'bars_id',
   { versioned => { since => '0.002' } },
);

__PACKAGE__->resultset_attributes( { versioned => { until => '0.003' } } );

...

package MyApp::Schema::Upgrade;

use base 'DBIx::Class::Schema::Versioned::Inline::Upgrade';
use DBIx::Class::Schema::Versioned::Inline::Upgrade qw/before after/;

before '0.3.3' => sub {
    my $schema = shift;
    $schema->resultset('Foo')->update({ bar => '' });
};

after '0.3.3' => sub {
    my $schema = shift;
    # do something else
};
```

# DESCRIPTION

This module extends [DBIx::Class::Schema::Versioned](https://metacpan.org/pod/DBIx::Class::Schema::Versioned) using simple
'since' and 'until' tokens within result classes to specify the
schema version at which classes and columns were introduced or
removed. Column since/until definitions are included as part of
'versioned' info in add\_column(s).

## since

When a class is added to a schema at a specific schema version
version then a 'since' attribute must be added to the class which
returns the version at which the class was added. For example:

```perl
__PACKAGE__->resultset_attributes({ versioned => { since => '0.002' }});
```

It is not necessary to add this to the initial version of a class
since any class without this atribute is assumed to have existed for
ever.

Using 'since' in a column or relationship definition denotes the
version at which the column/relation was added. For example:

```perl
__PACKAGE__->add_column(
   "age" => {
       data_type => "integer", is_nullable => 1,
       versioned => { since => '0.002' }
   }
);
```

For changes to column\_info such as a change of data\_type see ["changes"](#changes).

Note: if the Result containing the column includes a class-level
`since` then there is no need to add `since` markers for columns
created at the same version.

Relationships are handled in the same way as columns:

```perl
__PACKAGE__->belongs_to(
   'bar',
   'MyApp::Schema::Result::Bar',
   'bars_id',
   { versioned => { since => '0.002' } },
);
```

## until

When used as a class attribute this should be the schema version at
which the class is to be removed. The underlying database table will
be removed when the schema is upgraded to this version. Example
definitions:

```perl
__PACKAGE__->resultset_attributes({ versioned => { until => '0.7' }});

__PACKAGE__->add_column(
   "age" => {
       data_type => "integer", is_nullable => 1,
       versioned => { until => '0.5' }
   }
);
```

Using 'until' in a column or relationship definition will cause
removal of the column/relation from the table when the schema is
upgraded to this version.

## renamed\_from

This is always used alongside 'since' in the renamed class/column and
there must also be a corresponding 'until' on the old class/column.

NOTE: when renaming a class the 'renamed\_from' value is the table name
of the old class and NOT the class name.

For example when renaming a class:

```perl
package MyApp::Schema::Result::Foo;

__PACKAGE__->table('foos');
__PACKAGE__->resultset_attributes({ versioned => { until => '0.5 }});

package MyApp::Schema::Result::Fooey;

__PACKAGE__->table('fooeys');
__PACKAGE__->resultset_attributes({
   versioned => { since => '0.5, renamed_from => 'foos' }
});
```

And when renaming a column:

```perl
__PACKAGE__->add_columns(
   "height" => {
       data_type => "integer",
       versioned => { until => '0.002' }
   },
   "width" => {
       data_type => "integer", is_nullable => 0,
       versioned => { since => '0.002', renamed_from => 'height' }
   },
);
```

As can been seen in the example it is possible to modify column
definitions at the same time as a rename but care should be taken to
ensure that any data modification (such as ensuring there are no
longer null values when is\_nullable => 0 is introduced) must be
handled via ["Upgrade.pm"](#upgrade-pm).

NOTE: if columns are renamed at the same version that a class/table is
renamed (for example a renamed PK) then you MUST also add
`renamed_from` to the column as otherwise data from that column will
be lost. In this special situation adding `since` to the column is
not required.

## changes

Column definition changes are handled using the `changes` token. A
hashref is created for each version where the column definition
changes which details the new column definition in effect from that
change revision. For example:

```perl
__PACKAGE__->add_columns(
   "item_weight",
   {
       data_type => "integer", is_nullable => 1, default_value => 4,
       versioned => { until => '0.001 },
   },
   "weight",
   {
       data_type => "integer", is_nullable => 1,
       versioned => {
           since        => '0.002',
           renamed_from => 'item_weight',
           changes => {
               '0.4' => {
                   data_type   => "numeric",
                   size        => [10,2],
                   is_nullable => 1,
               }
               '0.401' => {
                   data_type   => "numeric",
                   size        => [10,2],
                   is_nullable => 0,
                   default_value => "0.0",
               }
           }
       }
   }
);
```

Note: the initial column definition should never be changed since that
is the definition to be used from when the column is first created
until the first change is effected.

## Upgrade.pm

For details on how to apply data modifications that might be required
during an upgrade see [DBIx::Class::Schema::Versioned::Inline::Upgrade](https://metacpan.org/pod/DBIx::Class::Schema::Versioned::Inline::Upgrade).

# VERSION NUMBERS

Under the hood all version numbers are handled using [Perl::Version](https://metacpan.org/pod/Perl::Version) which
can lead to confusion if you do not understand how Perl versions are
manipulated. For example:

```
$a = Perl::Version->new(0.4)
$b = Perl::Version->new(0.3)
$a > $b                           # TRUE
```

But things can start to look very odd as soon as we use different numbers of
decimal places:

```
$a = Perl::Version->new(0.12)
$b = Perl::Version->new(0.30)
$a > $b                           # TRUE
```

And just to add to potential confusion:

```
$a = Perl::Version->new(0.12)
$b = Perl::Version->new("0.30")
$a > $b                           # FALSE
```

The motto of this story is that you must be careful how you manage your
versions. Please read [Perl::Version](https://metacpan.org/pod/Perl::Version) pod carefully and make sure you
understand how it operates. To avoid unexpected behaviour it is recommended
that you **always** quote the version and if possible use a dotted-decimal
with at least three components or use simple cardinal numbers which can
never be confused.

# ATTRIBUTES

## schema\_versions

A [Set::Equivalence](https://metacpan.org/pod/Set::Equivalence) set of [PerVersion](https://metacpan.org/pod/Types::PerlVersion) objects
containing all of the available schema versions.

Versions should be added using ["add\_version"](#add_version).

# METHODS

Many methods are inherited or overloaded from [DBIx::Class::Schema::Versioned](https://metacpan.org/pod/DBIx::Class::Schema::Versioned).

## add\_version( $version \[, $v2, ... \] )

Adds one or more versions to ["schema\_versions"](#schema_versions) set. Arguments can either
be [PerlVersion](https://metacpan.org/pod/Types::PerlVersion) objects or simple scalars which will
be coerced into such.

## connection

Overloaded method. This checks the DBIC schema version against the DB
version and uses the DB version if it exists or the schema version if
the database is currently unversioned.

## deploy

Inherited method. Same as ["deploy" in DBIx::Class::Schema](https://metacpan.org/pod/DBIx::Class::Schema#deploy) but also
calls `install`.

## downgrade

Call this to attempt to downgrade your database from the version it
is at to the version this DBIC schema is at. If they are the same
it does nothing.

## downgrade\_single\_step

## install

Inherited method. Call this to initialise a previously unversioned
database.

## get\_db\_version

Override ["get\_db\_version" in DBIx::Class::Schema::Versioned](https://metacpan.org/pod/DBIx::Class::Schema::Versioned#get_db_version) to return the
version as a [PerlVersion](https://metacpan.org/pod/Types::PerlVersion) object.

## ordered\_schema\_versions

```perl
$self->ordered_schema_version('desc');
```

Optional argument defines the order (ascending or descending). With no arg
(or an arg we cannot determine direction from) results in ascending.

## schema\_first\_version

Returns the current schema class' $FIRST\_VERSION in a normalised way.

If the schema does not define $FIRST\_VERSION then all resultsets must
specify the version at which they were added using ["since"](#since).

## schema\_version

Override ["schema\_version" in DBIx::Class::Schema](https://metacpan.org/pod/DBIx::Class::Schema#schema_version) to return the version as
a [PerlVersion](https://metacpan.org/pod/Types::PerlVersion) object.

## stringified\_ordered\_schema\_versions

Calls ["ordered\_schema\_versions"](#ordered_schema_versions) with the same args and converts the returned
list elements to stringified versions.

## upgrade

Inherited method. Call this to attempt to upgrade your database from
the version it is at to the version this DBIC schema is at. If they
are the same it does nothing.

## upgrade\_single\_step

- Arguments: db\_version - the version currently within the db
- Arguments: target\_version - the version to upgrade to

Overloaded method. Call this to attempt to upgrade your database from
the _db\_version_ to the _target\_version_. If they are the same it
does nothing.

All upgrade operations within this step are performed inside a single
transaction so either all succeed or all fail. If successful the
dbix\_class\_schema\_versions table is updated with the _target\_version_.

This method may be called repeatedly by the ["upgrade"](#upgrade) method to
upgrade through a series of updates.

## versioned\_schema

- Arguments: version - the schema version we want to deploy

Parse schema and remove classes, columns and relationships that are
not valid for the requested version.

# CANDY

See [DBIx::Class::Schema::Versioned::Inline::Candy](https://metacpan.org/pod/DBIx::Class::Schema::Versioned::Inline::Candy).

# CAVEATS

Please anticipate API changes in this early state of development.

# TODO

- Sequence renaming in Pg, MySQL (maybe?). Not required for SQLite.
- Index renaming for auto-created indexes for UCs, etc - Pg + others?
- Downgrades
- Schema validation

# AUTHOR

Peter Mottram (SysPete), "peter@sysnix.com"

# CONTRIBUTORS

Slaven Rezić (eserte)
Stefan Hornburg (racke)
Peter Rabbitson (ribasushi)

# BUGS

This is BETA software so bugs and missing features are expected.

Please report any bugs or feature requests via the project's GitHub
issue tracker:

[https://github.com/Sysnix/dbix-class-schema-versioned-inline/issues](https://github.com/Sysnix/dbix-class-schema-versioned-inline/issues)

I will be notified, and then you'll automatically be notified of
progress on your bug as I make changes.

# SUPPORT

You can find documentation for this module with the perldoc command.

```
perldoc DBIx::Class::Schema::Versioned::Inline
```

You can also look for information at:

- GitHub repository

    [https://github.com/Sysnix/dbix-class-schema-versioned-inline](https://github.com/Sysnix/dbix-class-schema-versioned-inline)

- AnnoCPAN: Annotated CPAN documentation

    [http://annocpan.org/dist/DBIx-Class-Schema-Versioned-Inline](http://annocpan.org/dist/DBIx-Class-Schema-Versioned-Inline)

- CPAN Ratings

    [http://cpanratings.perl.org/d/DBIx-Class-Schema-Versioned-Inline](http://cpanratings.perl.org/d/DBIx-Class-Schema-Versioned-Inline)

- Search CPAN

    [http://search.cpan.org/dist/DBIx-Class-Schema-Versioned-Inline/](http://search.cpan.org/dist/DBIx-Class-Schema-Versioned-Inline/)

# ACKNOWLEDGEMENTS

Thanks to Best Practical Solutions for the [Jifty](https://metacpan.org/pod/Jifty) framework and
[Jifty::DBI](https://metacpan.org/pod/Jifty::DBI) which inspired this distribution. Many thanks to all of
the [DBIx::Class](https://metacpan.org/pod/DBIx::Class) and [SQL::Translator](https://metacpan.org/pod/SQL::Translator) developers for those
excellent distributions and especially to ribasushi and ilmari for all
of their help and input.

# LICENSE AND COPYRIGHT

Copyright 2014 Peter Mottram (SysPete).

This program is free software; you can redistribute it and/or modify
it under the terms of either: the GNU General Public License as
published by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.
