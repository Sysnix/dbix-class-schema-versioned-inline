#!perl

use Test::Roo;
use Test::PostgreSQL;
use File::Spec;
use lib File::Spec->catdir( 't', 'lib' );
use TestVersion::Schema;
with 'Deploy';

sub _build_database {
    my $self = shift;
    my $pgsql = Test::PostgreSQL->new() or die;
    return $pgsql;
}

sub connect_info {
    my $self = shift;
    return $self->database->dsn;
}

run_me;

done_testing;
