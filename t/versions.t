#!perl

use strict;
use warnings FATAL => 'all';

use Test::Most;

use Data::Dumper;
use DBICx::TestDatabase;
use File::Spec;
use Test::Mock::Simple;
use version 0.77;

use lib File::Spec->catdir( 't', 'lib' );

use MyApp::Schema;

$ENV{DBIC_NO_VERSION_CHECK} = 1;

my ( $mock, $rset, $schema, $source );

$schema = DBICx::TestDatabase->new('MyApp::Schema');

cmp_ok( $schema->get_db_version, 'eq', '0.000001', "Check db version" );
cmp_ok( $schema->schema_version, 'eq', '0.000001', "Check schema version" );

$mock = Test::Mock::Simple->new(module => 'MyApp::Schema');
$mock->add(schema_version => sub { return '0.001' } );

$schema = DBICx::TestDatabase->new('MyApp::Schema');

cmp_ok( $schema->get_db_version, 'eq', '0.001', "Check db version" );
cmp_ok( $schema->schema_version, 'eq', '0.001', "Check schema version" );

done_testing;
