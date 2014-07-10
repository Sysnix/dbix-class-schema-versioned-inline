#!perl

use File::Spec;
use lib File::Spec->catdir( 't', 'lib' );

use Test::Roo;
use TestVersion::Schema;
with 'Role::MySQL', 'Role::Upgrade';

run_me;
done_testing;
