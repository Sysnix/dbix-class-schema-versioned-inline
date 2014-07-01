package Deploy;
use Test::Roo::Role;

requires 'connect_info';

use Class::Unload;
use Test::Deep;
use Test::Most;

has database => (
    is => 'lazy',
    clearer => 1,
);

has schema_version => (
    is => 'rw',
    default => 0,
);

after each_test => sub {
    my $self = shift;
    $self->clear_database;
};

test 'deploy v0.001' => sub {
    my $self = shift;

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.001' };

    my $schema = TestVersion::Schema->connect($self->connect_info);

    my @versions = ( '0.001', '0.002', '0.003', '0.004', '0.005', '0.3' );

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

};

test 'deploy v0.002' => sub {
    my $self = shift;

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.002' };

    my $schema = TestVersion::Schema->connect($self->connect_info);

    my @versions = ( '0.001', '0.002', '0.003', '0.004', '0.005', '0.3' );

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

};

test 'deploy v0.003' => sub {
    my $self = shift;

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.003' };

    my $schema = TestVersion::Schema->connect($self->connect_info);

    my @versions = ( '0.001', '0.002', '0.003', '0.004', '0.005', '0.3' );

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
};

test 'deploy v0.3' => sub {
    my $self = shift;

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.3' };

    my $schema = TestVersion::Schema->connect($self->connect_info);

    my @versions = ( '0.001', '0.002', '0.003', '0.004', '0.005', '0.3' );

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
};

test 'deploy v0.4' => sub {
    my $self = shift;

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.4' };

    my $schema = TestVersion::Schema->connect($self->connect_info);

    my @versions = ( '0.001', '0.002', '0.003', '0.004', '0.005', '0.3', '0.4' );

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
};

1;
