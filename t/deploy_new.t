#!perl

use strict;
use warnings FATAL => 'all';

use Test::Most;

use Class::Unload;
use Data::Dumper;
use File::Spec;
use File::Temp;
use version 0.77;

use lib ( 'lib', File::Spec->catdir( 't', 'lib' ) );

use TestDeploy;

$ENV{DBIC_NO_VERSION_CHECK} = 1;

sub unload_classes {
    Class::Unload->unload('TestVersion::Schema::Result::Bar');
    Class::Unload->unload('TestVersion::Schema::Result::Foo');
    Class::Unload->unload('TestVersion::Schema::Result::Tree');
    Class::Unload->unload('TestVersion::Schema::Result::Schema');
}

SKIP: {
    eval { require DBD::SQLite };

    skip "DBD::SQLite not installed" if $@;

    diag "Testing with SQLite";

    #my $fh = File::Temp->new( TEMPLATE => 'deploy_test_XXXXX' );
    #my $dbfile = $fh->filename;

    my $tests = TestDeploy->new(
        connection_info => sub {
            return [
            "dbi:SQLite:dbname=:memory:", undef, undef,
            {
                sqlite_use_immediate_transaction => 0,
                on_connect_call => 'use_foreign_keys',
            },
        ]
        }
    );

    $tests->run_tests;
}


SKIP: {
    eval { require Test::PostgreSQL };

    skip "Test::PostgreSQL not installed" if $@;

    diag "Testing with PostgreSQL";

    my $tests = TestDeploy->new(
        connection_info => sub {
            my $pgsql = Test::PostgreSQL->new() or die;
            my @connection_info = ($pgsql->dsn);
            #print Dumper(@connection_info);
            return [ $pgsql->dsn ];
        }
    );

    $tests->run_tests;
}

done_testing;
