package Role::MySQL;

use Test::Roo::Role;
use Test::More;

eval "use DBD::mysql";
plan skip_all => "DBD::mysql required" if $@;

eval "use Test::mysqld";
plan skip_all => "Test::mysqld required" if $@;

sub _build_database {
    my $self = shift;
    my $mysqld = Test::mysqld->new( my_cnf => { 'skip-networking' => '' } )
      or die;
    return $mysqld;
}

sub connect_info {
    my $self = shift;
    return $self->database->dsn( dbname => 'test' );
}

1;
