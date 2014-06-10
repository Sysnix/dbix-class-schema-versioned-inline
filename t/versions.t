#!perl

use strict;
use warnings FATAL => 'all';

use Test::Most;

use lib File::Spec->catdir( 't', 'lib' );

use Data::Dumper;
use File::Spec;
use DBICx::TestDatabase;
use MyApp::Schema;

$ENV{DBIC_NO_VERSION_CHECK} = 1;

my ( $rset, $source );

my $schema = DBICx::TestDatabase->new('MyApp::Schema');

cmp_ok( $schema->get_db_version, 'eq', '0.002', "Check db version" );
cmp_ok( $schema->schema_version, 'eq', '0.002', "Check schema version" );

done_testing;
