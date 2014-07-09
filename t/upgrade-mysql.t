#!perl

use Test::Roo;

use File::Spec;
use lib File::Spec->catdir( 't', 'lib' );
use TestVersion::Schema;
with 'Role::MySQL', 'Role::Deploy';

run_me;

done_testing;
