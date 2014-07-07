#!perl

use Test::Roo;

use File::Spec;
use lib File::Spec->catdir( 't', 'lib' );
use TestVersion::Schema;
with 'Upgrade';

eval "use DBD::Pg";
plan skip_all => "DBD::Pg required" if $@;

eval "use Test::PostgreSQL";
plan skip_all => "Test::PostgreSQL required" if $@;

sub _build_database {
    my $self = shift;
    no warnings 'once';
    my $pgsql = Test::PostgreSQL->new()
        or plan skip_all => $Test::PostgreSQL::errstr;
    return $pgsql;
}

sub connect_info {
    my $self = shift;
    return ( $self->database->dsn, undef, undef,
        { on_connect_do => 'SET client_min_messages=WARNING;' } );
}

run_me;

done_testing;
