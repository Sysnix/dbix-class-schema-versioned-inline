#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'DBIx::Class::Schema::Versioned::Jiftyesque' ) || print "Bail out!\n";
}

diag( "Testing DBIx::Class::Schema::Versioned::Jiftyesque $DBIx::Class::Schema::Versioned::Jiftyesque::VERSION, Perl $], $^X" );
