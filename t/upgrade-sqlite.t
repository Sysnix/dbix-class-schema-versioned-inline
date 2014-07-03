#!perl

use Test::Roo;

use File::Spec;
use File::Temp;
use lib File::Spec->catdir( 't', 'lib' );
use TestVersion::Schema;
with 'Upgrade';

eval "use DBD::SQLite";
plan skip_all => "DBD::SQLite required" if $@;

my $fh = File::Temp->new( TEMPLATE => 'upgrade_test_XXXXX', EXLOCK => 0 );
my $dbfile = $fh->filename;

sub connect_info {
    return ( "dbi:SQLite:dbname=$dbfile" );
}

run_me;

done_testing;
