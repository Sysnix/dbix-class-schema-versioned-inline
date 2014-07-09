package Upgrade;

$ENV{DBIC_NO_VERSION_CHECK} = 1;

use Class::Unload;
use Data::Dumper;
use Test::Roo::Role;
use Test::Most;
use DBIx::Class::Schema::Loader qw/make_schema_at/;
use SQL::Translator;

my $sqlt_version = SQL::Translator->VERSION;

requires 'connect_info';

has database => (
    is      => 'lazy',
    clearer => 1,
);

before each_test => sub {
    my $self = shift;

    #print Dumper($self);
};

after each_test => sub {
    my $self = shift;
    Class::Unload->unload('Test::Schema');
};

test 'deploy 0.001' => sub {
    my $self = shift;

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.001' };

    my $schema = TestVersion::Schema->connect( $self->connect_info );

    lives_ok( sub { $schema->deploy }, "deploy schema" );

    cmp_ok( $schema->schema_version, 'eq', '0.001', "Check schema version" );
    cmp_ok( $schema->get_db_version, 'eq', '0.001', "Check db version" );

    cmp_deeply( [ $schema->sources ], [qw(Foo)], "class Foo only" );

    my $foo = $schema->source('Foo');
    cmp_deeply( [ $foo->columns ], bag(qw(foos_id height)), "Foo columns OK" );

    lives_ok(
        sub {
            $schema->populate( 'Foo',
                [ ['height'], map { [$_] } ( 1 .. 10 ), undef, undef ] );
        },
        "Insert records into Foo"
    );
    cmp_ok( $schema->resultset('Foo')->count, '==', 12, "12 Foos" );
    cmp_ok( $schema->resultset('Foo')->search( { height => undef } )->count,
        '==', 2, "2 null Foos" );

    my $aref = $schema->storage->dbh->selectcol_arrayref(
        q(SELECT height FROM foos ORDER BY foos_id ASC));
    cmp_deeply(
        $aref,
        [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, undef, undef ],
        "height values OK"
    );
};

test 'upgrade to 0.002' => sub {
    my $self = shift;

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.002' };

    my $schema = TestVersion::Schema->connect( $self->connect_info );

    cmp_ok( $schema->schema_version, 'eq', '0.002', "Check schema version" );
    cmp_ok( $schema->get_db_version, 'eq', '0.001', "Check db version" );

    # let's upgrade!

    lives_ok(
        sub { $schema->upgrade },
        "Upgrade " . $schema->get_db_version . " to " . $schema->schema_version
    );

    cmp_ok( $schema->get_db_version, 'eq', '0.002',
        "Check db version post upgrade" );
};

test 'test 0.002' => sub {
    my $self = shift;

    make_schema_at(
        'Test::Schema',
        {
            exclude => qr/dbix_class_schema_versions/,
            naming  => 'current',
        },
        [ $self->connect_info ],
    );

    my $schema = 'Test::Schema';

    cmp_bag( [ $schema->sources ], [qw(Bar Foo)], "Foo and Bar" );

    # columns
    my $foo = $schema->source('Foo');
    cmp_bag( [ Test::Schema::Result::Foo->columns ],
        [qw(age foos_id width)], "Foo columns OK" );
    my $bar = $schema->source('Bar');
    cmp_bag( [ $bar->columns ], [qw(bars_id weight)], "Bar columns OK" );
    cmp_ok( $schema->resultset('Foo')->count, '==', 12, "12 Foos" );
    cmp_ok( $schema->resultset('Bar')->count, '==', 1, "1 Bar" );

    my $aref = $schema->storage->dbh->selectcol_arrayref(
        q(SELECT width FROM foos ORDER BY foos_id ASC));
    cmp_deeply( $aref, [qw(1 2 3 4 5 6 7 8 9 10 20 20)], "width values OK" );
};

test 'upgrade to 0.003' => sub {
    my $self = shift;

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.003' };

    my $schema = TestVersion::Schema->connect( $self->connect_info );

    cmp_ok( $schema->schema_version, 'eq', '0.003', "Check schema version" );
    cmp_ok( $schema->get_db_version, 'eq', '0.002', "Check db version" );

    # let's upgrade!

    lives_ok(
        sub { $schema->upgrade },
        "Upgrade " . $schema->get_db_version . " to " . $schema->schema_version
    );

    cmp_ok( $schema->get_db_version, 'eq', '0.003',
        "Check db version post upgrade" );
};

test 'test 0.003' => sub {
    my $self = shift;

    make_schema_at(
        'Test::Schema',
        {
            exclude => qr/dbix_class_schema_versions/,
            naming  => 'current',
        },
        [ $self->connect_info ],
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

    my $aref = $schema->storage->dbh->selectcol_arrayref(
        q(SELECT width FROM trees ORDER BY trees_id ASC));
    cmp_deeply( $aref, [qw(1 2 3 4 5 6 7 8 9 10 20 20)], "width values OK" );
};

test 'upgrade to 0.3' => sub {
    my $self = shift;

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.3' };

    my $schema = TestVersion::Schema->connect( $self->connect_info );

    cmp_ok( $schema->schema_version, 'eq', '0.3',   "Check schema version" );
    cmp_ok( $schema->get_db_version, 'eq', '0.003', "Check db version" );

    # let's upgrade!

    lives_ok(
        sub { $schema->upgrade },
        "Upgrade " . $schema->get_db_version . " to " . $schema->schema_version
    );

    cmp_ok( $schema->get_db_version, 'eq', '0.3',
        "Check db version post upgrade" );
};

test 'test 0.3' => sub {
    my $self = shift;

    make_schema_at(
        'Test::Schema',
        {
            exclude => qr/dbix_class_schema_versions/,
            naming  => 'current',
        },
        [ $self->connect_info ],
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
};

test 'upgrade to 0.4' => sub {
    my $self = shift;

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.4' };

    my $schema = TestVersion::Schema->connect( $self->connect_info );

    cmp_ok( $schema->schema_version, 'eq', '0.4', "Check schema version" );
    cmp_ok( $schema->get_db_version, 'eq', '0.3', "Check db version" );

    # let's upgrade!

    lives_ok(
        sub { $schema->upgrade },
        "Upgrade " . $schema->get_db_version . " to " . $schema->schema_version
    );

    cmp_ok( $schema->get_db_version, 'eq', '0.4',
        "Check db version post upgrade" );
};

test 'test 0.4' => sub {
    my $self = shift;

    make_schema_at(
        'Test::Schema',
        {
            exclude => qr/dbix_class_schema_versions/,
            naming  => 'current',
        },
        [ $self->connect_info ],
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
    cmp_bag( [ $bar->columns ], [qw(age bars_id height)], "Bar columns OK" );
};

1;
