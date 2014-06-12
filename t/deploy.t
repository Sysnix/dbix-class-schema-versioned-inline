#!perl

use strict;
use warnings FATAL => 'all';

use Test::Most;

use Class::Unload;
use File::Spec;
use version 0.77;

use lib ( 'lib', File::Spec->catdir( 't', 'lib' ) );

$ENV{DBIC_NO_VERSION_CHECK} = 1;

my ( $rset, $schema, @versions );

VERSION_0_001: {

    use_ok 'TestVersion_v0_001';

    $schema = TestVersion::Schema->connect("dbi:SQLite:dbname=:memory:");

    @versions = ( '0.001', '0.002', '0.003', '0.004', '0.005', '0.3' );

    cmp_ok( $schema->schema_version, 'eq', '0.001', "Check schema version" );
    cmp_ok( $schema->get_db_version, '==', 0, "db version not defined yet" );

    lives_ok( sub { $schema->deploy }, "deploy schema" );
    cmp_ok( $schema->get_db_version, 'eq', '0.001', "Check db version" );

    cmp_deeply( [ $schema->ordered_schema_versions ],
        \@versions, "Check we found all expected versions" )
      || (diag "got: "
        . join( " ", $schema->ordered_schema_versions )
        . "\nexpect: "
        . join( " ", @versions ) );

    # tables
    cmp_deeply( [ $schema->sources ], [qw(Foo)], "class Foo only" );

    # columns
    my $foo = $schema->source('Foo');
    cmp_deeply( [ sort $foo->columns ], [qw(foos_id height)],
        "Foo columns OK" );

    Class::Unload->unload('TestVersion::Foo');
    Class::Unload->unload('TestVersion::Bar');
}

VERSION_0_002: {

    use_ok 'TestVersion_v0_002';

    $schema = TestVersion::Schema->connect("dbi:SQLite:dbname=:memory:");

    @versions = ( '0.001', '0.002', '0.003', '0.004', '0.005', '0.3' );

    cmp_ok( $schema->schema_version, 'eq', '0.002', "Check schema version" );
    cmp_ok( $schema->get_db_version, '==', 0, "db version not defined yet" );

    lives_ok( sub { $schema->deploy }, "deploy schema" );
    cmp_ok( $schema->get_db_version, 'eq', '0.002', "Check db version" );

    cmp_deeply( [ $schema->ordered_schema_versions ],
        \@versions, "Check we found all expected versions" )
      || (diag "got: "
        . join( " ", $schema->ordered_schema_versions )
        . "\nexpect: "
        . join( " ", @versions ) );

    # tables
    cmp_deeply( [ sort $schema->sources ], [qw(Bar Foo)], "Foo and Bar" );

    # columns
    my $foo = $schema->source('Foo');
    cmp_deeply(
        [ sort $foo->columns ],
        [qw(age foos_id height)],
        "Foo columns OK"
    );
    my $bar = $schema->source('Bar');
    cmp_deeply(
        [ sort $bar->columns ],
        [qw(age bars_id weight)],
        "Bar columns OK"
    );

    Class::Unload->unload('TestVersion::Foo');
    Class::Unload->unload('TestVersion::Bar');
}

VERSION_0_003: {

    use_ok 'TestVersion_v0_003';

    $schema = TestVersion::Schema->connect("dbi:SQLite:dbname=:memory:");

    @versions = ( '0.001', '0.002', '0.003', '0.004', '0.005', '0.3' );

    cmp_ok( $schema->schema_version, 'eq', '0.003', "Check schema version" );
    cmp_ok( $schema->get_db_version, '==', 0, "db version not defined yet" );

    lives_ok( sub { $schema->deploy }, "deploy schema" );
    cmp_ok( $schema->get_db_version, 'eq', '0.003', "Check db version" );

    cmp_deeply( [ $schema->ordered_schema_versions ],
        \@versions, "Check we found all expected versions" )
      || (diag "got: "
        . join( " ", $schema->ordered_schema_versions )
        . "\nexpect: "
        . join( " ", @versions ) );

    # tables

    cmp_deeply( [ sort $schema->sources ], [qw(Bar)], "Bar only" );

    # columns
    my $bar = $schema->source('Bar');
    cmp_deeply(
        [ sort $bar->columns ],
        [qw(age bars_id height weight)],
        "Bar columns OK"
    );

    Class::Unload->unload('TestVersion::Foo');
    Class::Unload->unload('TestVersion::Bar');
}

VERSION_0_3: {

    use_ok 'TestVersion_v0_3';

    $schema = TestVersion::Schema->connect("dbi:SQLite:dbname=:memory:");

    @versions = ( '0.001', '0.002', '0.003', '0.004', '0.005', '0.3' );

    cmp_ok( $schema->schema_version, 'eq', '0.3', "Check schema version" );
    cmp_ok( $schema->get_db_version, '==', 0, "db version not defined yet" );

    lives_ok( sub { $schema->deploy }, "deploy schema" );
    cmp_ok( $schema->get_db_version, 'eq', '0.3', "Check db version" );

    cmp_deeply( [ $schema->ordered_schema_versions ],
        \@versions, "Check we found all expected versions" )
      || (diag "got: "
        . join( " ", $schema->ordered_schema_versions )
        . "\nexpect: "
        . join( " ", @versions ) );

    # tables
    cmp_deeply( [ sort $schema->sources ], [qw(Bar)], "Bar only" );

    # columns
    my $bar = $schema->source('Bar');
    cmp_deeply(
        [ sort $bar->columns ],
        [qw(age bars_id height weight)],
        "Bar columns OK"
    );

    Class::Unload->unload('TestVersion::Foo');
    Class::Unload->unload('TestVersion::Bar');
}

VERSION_0_4: {

    use_ok 'TestVersion_v0_4';

    $schema = TestVersion::Schema->connect("dbi:SQLite:dbname=:memory:");

    @versions = ( '0.001', '0.002', '0.003', '0.004', '0.005', '0.3', '0.4' );

    cmp_ok( $schema->schema_version, 'eq', '0.4', "Check schema version" );
    cmp_ok( $schema->get_db_version, '==', 0, "db version not defined yet" );

    lives_ok( sub { $schema->deploy }, "deploy schema" );
    cmp_ok( $schema->get_db_version, 'eq', '0.4', "Check db version" );

    cmp_deeply( [ $schema->ordered_schema_versions ],
        \@versions, "Check we found all expected versions" )
      || (diag "got: "
        . join( " ", $schema->ordered_schema_versions )
        . "\nexpect: "
        . join( " ", @versions ) );

    # tables
    cmp_deeply( [ sort $schema->sources ], [qw(Bar)], "Bar only" );

    # columns
    my $bar = $schema->source('Bar');
    cmp_deeply(
        [ sort $bar->columns ],
        [qw(age bars_id height)],
        "Bar columns OK"
    );

    Class::Unload->unload('TestVersion::Foo');
    Class::Unload->unload('TestVersion::Bar');
}

done_testing;
