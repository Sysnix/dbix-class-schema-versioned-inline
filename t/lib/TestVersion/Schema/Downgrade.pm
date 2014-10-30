package TestVersion::Schema::Downgrade;

use base 'DBIx::Class::Schema::Versioned::Inline::Downgrade';
use DBIx::Class::Schema::Versioned::Inline::Downgrade qw/before after/;

before '0.001' => sub {
    my $schema = shift;
    $schema->resultset('Bar')->search({ weight => 20 })->delete;
    $schema->resultset('Foo')->search({ width => 30 })->delete;
};

before '0.002' => sub {
    my $schema = shift;
    $schema->resultset('Tree')->search({ width => 40 })->delete;
};

1;
