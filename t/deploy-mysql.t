#!perl

use File::Spec;
use lib File::Spec->catdir( 't', 'lib' );

use Test::Roo;
use TestVersion::Schema;
with 'Role::MySQL', 'Role::Deploy';

diag "Tests run slowly due to repeated database creation/destruction.";

run_me;
done_testing;
