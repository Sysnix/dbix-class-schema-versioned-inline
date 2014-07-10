#!perl

use Test::Roo;

use File::Spec;
use File::Temp;
use lib File::Spec->catdir( 't', 'lib' );
use TestVersion::Schema;
with 'Role::Upgrade';

eval "use DBD::SQLite";
plan skip_all => "DBD::SQLite required" if $@;

my $fh = File::Temp->new( TEMPLATE => 'upgrade_test_XXXXX', EXLOCK => 0 );
my $dbfile = $fh->filename;

sub connect_info {
    return ( "dbi:SQLite:dbname=$dbfile" );
}

SKIP: {
    skip "column rename_from broken in SQLT 0.11018 set NOSKIP ENV to force", 1
      unless $ENV{NOSKIP};
    run_me;
};
done_testing;
