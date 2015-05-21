package Role::SQLite;

use Class::Load qw(try_load_class);
use File::Spec;

use Test::Roo::Role;
with 'Role::Database';

sub BUILD {
    try_load_class("DBD::SQLite") or plan skip_all => "DBD::SQLite required";
}

my ($dbfile) = File::Spec->catfile( File::Spec->tmpdir, "dcsvi_test_$$" );

before clear_database => sub {
    my $database = shift->database;
    $database->disconnect if $database;
};
after clear_database => sub {
    unlink($dbfile) if -f $dbfile;
};
after teardown => sub {
    shift->clear_database;
};

sub _build_database {

    # does nothing atm for SQLite
    return;
}

sub _build_dbd_version {
    return "DBD::SQLite $DBD::SQLite::VERSION";
}

sub connect_info {
    my $self = shift;

    return (
        "dbi:SQLite:dbname=$dbfile",
        undef, undef,
        {
            sqlite_unicode  => 1,
            on_connect_call => 'use_foreign_keys',
            on_connect_do   => 'PRAGMA synchronous = OFF',
            quote_names     => 1,
        }
    );

}

sub _build_database_info {
    my $self = shift;
    return "SQLite library version: "
      . $self->schema->storage->dbh->{sqlite_version};
}

1;
