#!perl

use Test::Roo;

use File::Spec;
use lib File::Spec->catdir( 't', 'lib' );
use TestVersion::Schema;
with 'Role::PostgreSQL', 'Role::Upgrade';

SKIP: {
    skip "Pg table rename_from broken in SQL::Translator 0.11018", 1;
    run_me;
};

done_testing;
