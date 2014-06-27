#!perl

use strict;
use warnings FATAL => 'all';

use Test::Most;
use Test::PostgreSQL;

use Class::Unload;
use Data::Dumper::Concise;
use DBIx::Class::Schema::Loader qw/make_schema_at/;
use File::Spec;
use version 0.77;

use lib ( 'lib', File::Spec->catdir( 't', 'lib' ) );

my ( $rset, $schema, @versions );

$ENV{DBIC_NO_VERSION_CHECK} = 1;

my $pgsql = Test::PostgreSQL->new() or die;

DEPLOY_0_001: {

    # deploy 0.001

    use_ok 'TestVersion_v0_001';

    $schema = TestVersion::Schema->connect($pgsql->dsn);

    # deploy (also installs initial version)

    lives_ok( sub { $schema->deploy }, "deploy schema" );

    cmp_ok( $schema->schema_version, 'eq', '0.001', "Check schema version" );
    cmp_ok( $schema->get_db_version, 'eq', '0.001', "Check db version" );

    Class::Unload->unload('TestVersion::Schema');
    Class::Unload->unload('TestVersion::Foo');
    Class::Unload->unload('TestVersion::Bar');
}

UPGRADE_0_002: {

    # upgrade to 0.002

    use_ok 'TestVersion_v0_002';

    $schema = TestVersion::Schema->connect($pgsql->dsn);

    cmp_ok( $schema->schema_version, 'eq', '0.002', "Check schema version" );
    cmp_ok( $schema->get_db_version, 'eq', '0.001', "Check db version" );

    # let's upgrade!

    lives_ok(
        sub { $schema->upgrade },
        "Upgrade " . $schema->get_db_version . " to " . $schema->schema_version
    );

    cmp_ok( $schema->get_db_version, 'eq', '0.002',
        "Check db version post upgrade" );

    Class::Unload->unload('TestVersion::Schema');
    Class::Unload->unload('TestVersion::Foo');
    Class::Unload->unload('TestVersion::Bar');
}

TEST_0_002: {

    make_schema_at(
        'Test::Schema',
        {
            #debug => 1,
            exclude => qr/dbix_class_schema_versions/,
            naming  => 'current',
        },
        [ $pgsql->dsn ],
    );

    my $schema = 'Test::Schema';

    cmp_bag( [ $schema->sources ], [qw(Bar Foo)], "Foo and Bar" );

    # columns
    my $foo = $schema->source('Foo');
    cmp_bag(
        [ Test::Schema::Result::Foo->columns ],
        [qw(age bars_id foos_id width)],
        "Foo columns OK"
    );
    my $bar = $schema->source('Bar');
    cmp_bag(
        [ $bar->columns ],
        [qw(age bars_id weight)],
        "Bar columns OK"
    );

    Class::Unload->unload('Test::Schema');
    Class::Unload->unload('Test::Schema::Result::Foo');
    Class::Unload->unload('Test::Schema::Result::Bar');
}

UPGRADE_0_003: {

    use_ok 'TestVersion_v0_003';

    $schema = TestVersion::Schema->connect($pgsql->dsn);

    cmp_ok( $schema->schema_version, 'eq', '0.003', "Check schema version" );
    cmp_ok( $schema->get_db_version, 'eq', '0.002', "Check db version" );

    # let's upgrade!

    lives_ok(
        sub { $schema->upgrade },
        "Upgrade " . $schema->get_db_version . " to " . $schema->schema_version
    );

    cmp_ok( $schema->get_db_version, 'eq', '0.003',
        "Check db version post upgrade" );

    Class::Unload->unload('TestVersion::Schema');
    Class::Unload->unload('TestVersion::Foo');
    Class::Unload->unload('TestVersion::Bar');
    Class::Unload->unload('TestVersion::Tree');
}

TEST_0_003: {

    make_schema_at(
        'Test::Schema',
        {
            #debug => 1,
            exclude => qr/dbix_class_schema_versions/,
            naming  => 'current',
        },
        [ $pgsql->dsn ],
    );

    my $schema = 'Test::Schema';

    cmp_bag( [ $schema->sources ], [qw(Bar Tree)], "Tree and Bar" )
      or diag Dumper( $schema->sources );

    # columns
    my $tree = $schema->source('Tree');
    cmp_bag(
        [ Test::Schema::Result::Tree->columns ],
        [qw(age bars_id trees_id width)],
        "Tree columns OK"
    );
    my $bar = $schema->source('Bar');
    cmp_bag(
        [ $bar->columns ],
        [qw(age bars_id height weight)],
        "Bar columns OK"
    );

    Class::Unload->unload('Test::Schema');
    Class::Unload->unload('Test::Schema::Result::Tree');
    Class::Unload->unload('Test::Schema::Result::Bar');
}

UPGRADE_0_3: {

    use_ok 'TestVersion_v0_3';

    $schema = TestVersion::Schema->connect($pgsql->dsn);

    cmp_ok( $schema->schema_version, 'eq', '0.3',   "Check schema version" );
    cmp_ok( $schema->get_db_version, 'eq', '0.003', "Check db version" );

    # let's upgrade!

    lives_ok(
        sub { $schema->upgrade },
        "Upgrade " . $schema->get_db_version . " to " . $schema->schema_version
    );

    cmp_ok( $schema->get_db_version, 'eq', '0.3',
        "Check db version post upgrade" );

    Class::Unload->unload('TestVersion::Schema');
    Class::Unload->unload('TestVersion::Foo');
    Class::Unload->unload('TestVersion::Bar');
    Class::Unload->unload('TestVersion::Tree');
}

TEST_0_3: {

    make_schema_at(
        'Test::Schema',
        {
            #debug => 1,
            exclude => qr/dbix_class_schema_versions/,
            naming  => 'current',
        },
        [ $pgsql->dsn ],
    );

    my $schema = 'Test::Schema';

    cmp_bag( [ $schema->sources ], [qw(Tree Bar)], "Tree and Bar" )
      or diag Dumper( $schema->sources );

    # columns
    my $tree = $schema->source('Tree');
    cmp_bag(
        [ Test::Schema::Result::Tree->columns ],
        [qw(trees_id age bars_id width)],
        "Tree columns OK"
    );
    my $bar = $schema->source('Bar');
    cmp_bag(
        [ $bar->columns ],
        [qw(age bars_id height weight)],
        "Bar columns OK"
    );

    Class::Unload->unload('Test::Schema');
    Class::Unload->unload('Test::Schema::Result::Tree');
    Class::Unload->unload('Test::Schema::Result::Bar');
}

UPGRADE_0_4: {

    use_ok 'TestVersion_v0_4';

    $schema = TestVersion::Schema->connect($pgsql->dsn);

    cmp_ok( $schema->schema_version, 'eq', '0.4', "Check schema version" );
    cmp_ok( $schema->get_db_version, 'eq', '0.3', "Check db version" );

    # let's upgrade!

    lives_ok(
        sub { $schema->upgrade },
        "Upgrade " . $schema->get_db_version . " to " . $schema->schema_version
    );

    cmp_ok( $schema->get_db_version, 'eq', '0.4',
        "Check db version post upgrade" );

    Class::Unload->unload('TestVersion::Schema');
    Class::Unload->unload('TestVersion::Foo');
    Class::Unload->unload('TestVersion::Bar');
    Class::Unload->unload('TestVersion::Tree');
}

TEST_0_4: {

    make_schema_at(
        'Test::Schema',
        {
            #debug => 1,
            exclude => qr/dbix_class_schema_versions/,
            naming  => 'current',
        },
        [ $pgsql->dsn ],
    );

    my $schema = 'Test::Schema';

    cmp_bag( [ $schema->sources ], [qw(Bar Tree)], "Tree and Bar" )
      or diag Dumper( $schema->sources );

    # columns
    my $tree = $schema->source('Tree');
    cmp_bag(
        [ Test::Schema::Result::Tree->columns ],
        [qw(age bars_id trees_id width)],
        "Tree columns OK"
    );
    my $bar = $schema->source('Bar');
    cmp_bag(
        [ $bar->columns ],
        [qw(age bars_id height)],
        "Bar columns OK"
    );

    Class::Unload->unload('Test::Schema');
    Class::Unload->unload('Test::Schema::Result::Tree');
    Class::Unload->unload('Test::Schema::Result::Bar');
}

done_testing;
