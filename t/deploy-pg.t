#!perl

use Test::Roo;

use File::Spec;
use lib File::Spec->catdir( 't', 'lib' );
use TestVersion::Schema;
with 'Role::PostgreSQL', 'Role::Deploy';

diag "Notice: tests are slow due to repeated database creation.";

run_me;

done_testing;
