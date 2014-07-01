#!perl

use Test::Roo;

use File::Spec;
use lib File::Spec->catdir( 't', 'lib' );
use TestVersion::Schema;
with 'Deploy';

eval "use DBD::SQLite";
plan skip_all => "DBD::SQLite required" if $@;

sub connect_info {
    return (
        "dbi:SQLite:dbname=:memory:",
        undef, undef,
        {
            sqlite_use_immediate_transaction => 0,
            on_connect_call                  => 'use_foreign_keys'
        }
    );
}

run_me;

done_testing;
