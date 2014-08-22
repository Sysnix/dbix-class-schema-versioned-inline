#!perl

use File::Spec;
use lib File::Spec->catdir( 't', 'lib' );

use Test::Roo;
use TestVersion::Schema;
with 'Role::PostgreSQL', 'Role::Upgrade';

run_me;

done_testing;
