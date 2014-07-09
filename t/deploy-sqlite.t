#!perl

use Test::Roo;

use File::Spec;
use lib File::Spec->catdir( 't', 'lib' );
use TestVersion::Schema;
with 'Role::Deploy';

eval "use DBD::SQLite";
plan skip_all => "DBD::SQLite required" if $@;

sub connect_info {
    return ( "dbi:SQLite:dbname=:memory:" );
}

run_me;

done_testing;
