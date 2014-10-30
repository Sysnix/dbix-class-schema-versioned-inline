package Test::Downgrade;

$ENV{DBIC_NO_VERSION_CHECK} = 1;

use Data::Dumper::Concise;
use Class::Unload;
use Test::Roo::Role;
use Test::Deep;
use Test::Exception;
use DBIx::Class::Schema::Loader qw/make_schema_at/;
use SQL::Translator;

my $sqlt_version = SQL::Translator->VERSION;

after each_test => sub {
    my $self = shift;
    Class::Unload->unload('Test::Schema');
};

test 'deploy 0.4' => sub {
    my $self = shift;

    diag "Test::Downgrade with " . $self->schema_class;

    # paranoia: we might not be the first test (and want no warnings from this)
    {
        local $SIG{__WARN__} = sub {};
        $self->clear_database;
    }

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.4' };

    my $schema = $self->schema_class->connect( $self->connect_info );

    lives_ok( sub { $schema->deploy }, "deploy schema" );

    cmp_ok( $schema->schema_version, 'eq', '0.4', "Check schema version" );
    cmp_ok( $schema->get_db_version, 'eq', '0.4', "Check db version" );

    cmp_bag( [ $schema->sources ], [qw(Bar Tree)], "Tree and Bar" )
      or diag Dumper( $schema->sources );

    # columns
    my $tree = $schema->source('Tree');
    cmp_bag(
        [ $tree->columns ],
        [qw(age bars_id trees_id width)],
        "Tree columns OK"
    );
    my $bar = $schema->source('Bar');
    cmp_bag( [ $bar->columns ], [qw(age bars_id height)], "Bar columns OK" );

    # add some data
    $schema->resultset('Bar')->create( { age => 0, height => undef } );
    $schema->resultset('Tree')
      ->populate( [ ['width'], [1], [2], [3], [4], [20], [20], [30], [40], ] );

};

test 'downgrade to 0.003' => sub {
    my $self = shift;

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.003' };

    my $schema = $self->schema_class->connect( $self->connect_info );

    cmp_ok( $schema->schema_version, 'eq', '0.003', "Check schema version" );
    cmp_ok( $schema->get_db_version, 'eq', '0.4', "Check db version" );

    # let's downgrade!

    lives_ok(
        sub { $schema->downgrade },
        "Downgrade "
          . $schema->get_db_version . " to "
          . $schema->schema_version
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

    my $aref = $schema->storage->dbh->selectall_arrayref(
        q(SELECT trees_id,width FROM trees ORDER BY trees_id ASC));
    cmp_deeply(
        $aref,
        [[1,1],[2,2],[3,3],[4,4],[5,20],[6,20],[7,30],[8,40]],
        "width values OK"
    ) || diag Dumper $aref;
};

test 'downgrade to 0.002' => sub {
    my $self = shift;

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.002' };

    my $schema = $self->schema_class->connect( $self->connect_info );

    cmp_ok( $schema->schema_version, 'eq', '0.002', "Check schema version" );
    cmp_ok( $schema->get_db_version, 'eq', '0.003', "Check db version" );

    # let's downgrade!

    lives_ok(
        sub { $schema->downgrade },
        "Downgrade "
          . $schema->get_db_version . " to "
          . $schema->schema_version
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
    cmp_ok( $schema->resultset('Foo')->count, '==', 7, "7 Foos" );
    cmp_ok( $schema->resultset('Bar')->count, '==', 1, "1 Bar" );

    my $aref = $schema->storage->dbh->selectall_arrayref(
        q(SELECT foos_id,width FROM foos ORDER BY foos_id ASC));
    cmp_deeply(
        $aref,
        [[1,1],[2,2],[3,3],[4,4],[5,20],[6,20],[7,30]],
        "width values OK"
    ) || diag Dumper $aref;
};

test 'downgrade to 0.001' => sub {
    my $self = shift;

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.001' };

    my $schema = $self->schema_class->connect( $self->connect_info );

    cmp_ok( $schema->schema_version, 'eq', '0.001', "Check schema version" );
    cmp_ok( $schema->get_db_version, 'eq', '0.002', "Check db version" );

    # let's downgrade!

    lives_ok(
        sub { $schema->downgrade },
        "Downgrade "
          . $schema->get_db_version . " to "
          . $schema->schema_version
    );

    cmp_ok( $schema->get_db_version, 'eq', '0.001',
        "Check db version post upgrade" );
};

test 'test 0.001' => sub {
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

    cmp_deeply( [ $schema->sources ], [qw(Foo)], "class Foo only" );

    my $foo = $schema->source('Foo');
    cmp_deeply( [ $foo->columns ], bag(qw(foos_id height)), "Foo columns OK" );

    cmp_ok( $schema->resultset('Foo')->count, '==', 6, "6 Foos" );

    my $aref = $schema->storage->dbh->selectall_arrayref(
        q(SELECT foos_id, height FROM foos ORDER BY foos_id ASC));
    cmp_deeply(
        $aref,
        [[1,1],[2,2],[3,3],[4,4],[5,20],[6,20]],
        "height values OK"
    ) || diag Dumper $aref;
};
1;
