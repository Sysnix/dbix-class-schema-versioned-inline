package Deploy;

$ENV{DBIC_NO_VERSION_CHECK} = 1;

use Test::Roo::Role;
use Test::Most;

requires 'connect_info';

has database => (
    is      => 'lazy',
    clearer => 1,
);

after each_test => sub {
    my $self = shift;
    $self->clear_database;
};

test 'deploy v0.001' => sub {
    my $self = shift;

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.001' };

    my $schema = TestVersion::Schema->connect( $self->connect_info );

    my @versions = ( '0.001', '0.002', '0.003', '0.004', '0.005', '0.4' );

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
    cmp_deeply( [ $schema->sources ], bag(qw(Foo)), "class Foo only" );

    # columns
    my $foo = $schema->source('Foo');
    cmp_deeply( [ $foo->columns ], bag(qw(foos_id height)), "Foo columns OK" );

    # column info
    my $foo_columns_expect = {
        foos_id => {
            data_type         => 'integer',
            is_auto_increment => 1
        },
        height => {
            data_type   => "integer",
            is_nullable => 1,
            versioned   => { until => '0.002' }
        }
    };
    cmp_deeply( $foo->_columns, $foo_columns_expect, "Foo column info OK" );
};

test 'deploy v0.002' => sub {
    my $self = shift;

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.002' };

    my $schema = TestVersion::Schema->connect( $self->connect_info );

    my @versions = ( '0.001', '0.002', '0.003', '0.004', '0.005', '0.4' );

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
    cmp_deeply( [ $bar->columns ], bag(qw(bars_id weight)), "Bar columns OK" );
    my $foo = $schema->source('Foo');
    cmp_deeply(
        [ $foo->columns ],
        bag(qw(age foos_id width)),
        "Foo columns OK"
    );

    # column info & relations
    my $bar_columns = {
        bars_id => {
            data_type         => "integer",
            is_auto_increment => 1
        },
        weight => {
            data_type   => "integer",
            is_nullable => 1,
            versioned   => {
                until => "0.4"
            }
        }
    };
    my $foo_columns = {
        foos_id => {
            data_type         => 'integer',
            is_auto_increment => 1
        },
        age => {
            data_type   => "integer",
            is_nullable => 1,
            versioned   => { since => '0.002' }
        },
        width => {
            data_type     => "integer",
            is_nullable   => 0,
            default_value => 1,
            versioned     => { since => '0.002', renamed_from => 'height' },
            extra => { renamed_from => 'height' }
        },
    };
    cmp_deeply( $bar->_columns, $bar_columns, "Bar column info OK" );
    cmp_deeply( $foo->_columns, $foo_columns, "Foo column info OK" );
};

test 'deploy v0.003' => sub {
    my $self = shift;

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.003' };

    my $schema = TestVersion::Schema->connect( $self->connect_info );

    my @versions = ( '0.001', '0.002', '0.003', '0.004', '0.005', '0.4' );

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
        [ $bar->columns ],
        bag(qw(age bars_id height weight)),
        "Bar columns OK"
    );
    my $tree = $schema->source('Tree');
    cmp_deeply(
        [ $tree->columns ],
        bag(qw(age bars_id trees_id width)),
        "Tree columns OK"
    );

    # column info & relations
    my $bar_columns = {
        bars_id => {
            data_type         => "integer",
            is_auto_increment => 1
        },
        age => {
            data_type   => "integer",
            is_nullable => 1,
            versioned   => {
                since   => '0.003',
                changes => {
                    '0.004' => {
                        data_type     => "integer",
                        is_nullable   => 0,
                        default_value => 18
                    },
                }
            }
        },
        height => {
            data_type   => "integer",
            is_nullable => 1,
            versioned   => {
                since => "0.003"
            }
        },
        weight => {
            data_type   => "integer",
            is_nullable => 1,
            versioned   => {
                until => "0.4"
            }
        }
    };
    my $tree_columns = {
        "trees_id" => { data_type => 'integer', is_auto_increment => 1 },
        "age"      => { data_type => "integer", is_nullable       => 1 },
        "width" =>
          { data_type => "integer", is_nullable => 0, default_value => 1 },
        "bars_id" =>
          { data_type => 'integer', is_foreign_key => 1, is_nullable => 1 },
    };
    my $bar_relations = {
        trees => {
            attrs => {
                accessor       => "multi",
                cascade_copy   => 1,
                cascade_delete => 1,
                join_type      => "LEFT",
                versioned      => {
                    since => "0.003"
                }
            },
            class => "TestVersion::Schema::Result::Tree",
            cond  => {
                "foreign.trees_id" => "self.bars_id"
            },
            source => "TestVersion::Schema::Result::Tree"
        }
    };
    my $tree_relations = {
        bar => {
            attrs => {
                accessor   => "single",
                fk_columns => {
                    bars_id => 1
                },
                is_foreign_key_constraint => 1,
                undef_on_null_fk          => 1,
            },
            class => "TestVersion::Schema::Result::Bar",
            cond  => {
                "foreign.bars_id" => "self.bars_id"
            },
            source => "TestVersion::Schema::Result::Bar"
        }
    };
    cmp_deeply( $bar->_columns,        $bar_columns,    "Bar column info OK" );
    cmp_deeply( $tree->_columns,       $tree_columns,   "Tree column info OK" );
    cmp_deeply( $bar->_relationships,  $bar_relations,  "Bar relations OK" );
    cmp_deeply( $tree->_relationships, $tree_relations, "Tree relations OK" );
};

test 'deploy v0.4' => sub {
    my $self = shift;

    no warnings 'redefine';
    local *DBIx::Class::Schema::schema_version = sub { '0.4' };

    my $schema = TestVersion::Schema->connect( $self->connect_info );

    my @versions = ( '0.001', '0.002', '0.003', '0.004', '0.005', '0.4' );

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
        [ $bar->columns ],
        bag(qw(age bars_id height)),
        "Bar columns OK"
    );
    my $tree = $schema->source('Tree');
    cmp_deeply(
        [ $tree->columns ],
        bag(qw(age bars_id trees_id width)),
        "Tree columns OK"
    );

    # column info & relations
    my $bar_columns = {
        bars_id => {
            data_type         => "integer",
            is_auto_increment => 1
        },
        age => {
            data_type     => "integer",
            is_nullable   => 0,
            default_value => 18
        },
        height => {
            data_type   => "integer",
            is_nullable => 1,
            versioned   => {
                since => "0.003"
            }
        },
    };
    my $tree_columns = {
        "trees_id" => { data_type => 'integer', is_auto_increment => 1 },
        "age"      => { data_type => "integer", is_nullable       => 1 },
        "width" =>
          { data_type => "integer", is_nullable => 0, default_value => 1 },
        "bars_id" =>
          { data_type => 'integer', is_foreign_key => 1, is_nullable => 1 },
    };
    my $bar_relations = {
        trees => {
            attrs => {
                accessor       => "multi",
                cascade_copy   => 1,
                cascade_delete => 1,
                join_type      => "LEFT",
                versioned      => {
                    since => "0.003"
                }
            },
            class => "TestVersion::Schema::Result::Tree",
            cond  => {
                "foreign.trees_id" => "self.bars_id"
            },
            source => "TestVersion::Schema::Result::Tree"
        }
    };
    my $tree_relations = {
        bar => {
            attrs => {
                accessor   => "single",
                fk_columns => {
                    bars_id => 1
                },
                is_foreign_key_constraint => 1,
                undef_on_null_fk          => 1,
            },
            class => "TestVersion::Schema::Result::Bar",
            cond  => {
                "foreign.bars_id" => "self.bars_id"
            },
            source => "TestVersion::Schema::Result::Bar"
        }
    };
    cmp_deeply( $bar->_columns,        $bar_columns,    "Bar column info OK" );
    cmp_deeply( $tree->_columns,       $tree_columns,   "Tree column info OK" );
    cmp_deeply( $bar->_relationships,  $bar_relations,  "Bar relations OK" );
    cmp_deeply( $tree->_relationships, $tree_relations, "Tree relations OK" );
};

1;
