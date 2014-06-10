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

cmp_ok( $schema->get_db_version, 'eq', '0.001', "Check db version" );
cmp_ok( $schema->schema_version, 'eq', '0.001', "Check schema version" );

print "\n\n";

$source = $schema->source('Tree');
print (join("\n", $source->columns));

print "\n\n";
$source = $schema->source('Tree');
print (join("\n", $source->columns));
#print (Dumper($source->columns_info));

#print Dumper($source->hello);

#my $since = $source->since;

#print "xx $since xx\n";

#print STDERR "xx\n" . Dumper( $schema->ordered_schema_versions ) . "xx\n";
#print STDERR join("\n", $schema->sources);

#lives_ok( sub { $schema->install( '0.001' ) }, "Install schema at v 0.001" );
#print "xx\n";
#print "xx\n";

done_testing;
