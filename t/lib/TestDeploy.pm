package TestDeploy;

use strict;
use warnings;

use Class::Unload;
use Moo;
use namespace::clean;
use Test::Most;

use Data::Dumper::Concise;

has schema => (
    is => 'rw',
);

my ( $rset, @versions );

sub unload_classes {
    Class::Unload->unload('TestVersion::Schema::Result::Bar');
    Class::Unload->unload('TestVersion::Schema::Result::Foo');
    Class::Unload->unload('TestVersion::Schema::Result::Tree');
    Class::Unload->unload('TestVersion::Schema::Result::Schema');
}

sub run_tests {
    my $self = shift;

VERSION_0_001: {

    use_ok 'TestVersion::Schema';

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.001' };
    use warnings 'redefine';

    #use Test::PostgreSQL;
    #my $pgsql = Test::PostgreSQL->new() or die;
    #$schema = TestVersion::Schema->connect($pgsql->dsn);

    $schema = TestVersion::Schema->connect(@{$self->get_conn_info});

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
        "Foo columns OK" )
      || diag "got: "
        . join( " ", $foo->columns );

    unload_classes();
}
}
1;
__END__
VERSION_0_002: {

    use_ok 'TestVersion::Schema';

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.002' };
    use warnings 'redefine';

    $schema = TestVersion::Schema->connect($self->get_conn_info);

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
    cmp_deeply( [ $schema->sources ], bag(qw(Bar Foo)), "Bar and Foo" );

    # columns
    my $bar = $schema->source('Bar');
    cmp_deeply(
        [ sort $bar->columns ],
        [qw(age bars_id weight)],
        "Bar columns OK"
    );
    my $foo = $schema->source('Foo');
    cmp_deeply(
        [ sort $foo->columns ],
        [qw(age bars_id foos_id width)],
        "Foo columns OK"
    );

    unload_classes();
}

VERSION_0_003: {

    use_ok 'TestVersion::Schema';

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.003' };
    use warnings 'redefine';

    $schema = TestVersion::Schema->connect($self->get_conn_info);

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

    cmp_deeply( [ $schema->sources ], bag(qw(Bar Tree)), "Bar and Tree" );

    # columns
    my $bar = $schema->source('Bar');
    cmp_deeply(
        [ sort $bar->columns ],
        [qw(age bars_id height weight)],
        "Bar columns OK"
    );
    my $tree = $schema->source('Tree');
    cmp_deeply(
        [ sort $tree->columns ],
        [qw(age bars_id trees_id width)],
        "Tree columns OK"
    );

    unload_classes();
}

VERSION_0_3: {

    use_ok 'TestVersion::Schema';

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.3' };
    use warnings 'redefine';

    $schema = TestVersion::Schema->connect($self->get_conn_info);

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
    cmp_deeply( [ $schema->sources ], bag(qw(Bar Tree)), "Bar and Tree" );

    # columns
    my $bar = $schema->source('Bar');
    cmp_deeply(
        [ sort $bar->columns ],
        [qw(age bars_id height weight)],
        "Bar columns OK"
    );
    my $tree = $schema->source('Tree');
    cmp_deeply(
        [ sort $tree->columns ],
        [qw(age bars_id trees_id width)],
        "Tree columns OK"
    );

    unload_classes();
}

VERSION_0_4: {

    use_ok 'TestVersion::Schema';

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.4' };
    use warnings 'redefine';

    $schema = TestVersion::Schema->connect($self->get_conn_info);

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
    cmp_deeply( [ $schema->sources ], bag(qw(Bar Tree)), "Bar and Tree" );

    # columns
    my $bar = $schema->source('Bar');
    cmp_deeply(
        [ sort $bar->columns ],
        [qw(age bars_id height)],
        "Bar columns OK"
    );
    my $tree = $schema->source('Tree');
    cmp_deeply(
        [ sort $tree->columns ],
        [qw(age bars_id trees_id width)],
        "Tree columns OK"
    );

    unload_classes();
}
}
1;
