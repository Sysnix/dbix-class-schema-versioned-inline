#!perl

use File::Spec;
use lib File::Spec->catdir( 't', 'lib' );

use Test::Roo;
use TestVersion::Schema;
with 'Role::PostgreSQL', 'Role::Upgrade';

SKIP: {
    skip "table rename_from broken in SQLT 0.11018 set NOSKIP ENV to force", 1
      unless $ENV{NOSKIP};
    run_me;
};
done_testing;
