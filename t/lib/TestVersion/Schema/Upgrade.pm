package TestVersion::Schema::Upgrade;

use base 'DBIx::Class::Schema::Versioned::Inline::Upgrade';
use DBIx::Class::Schema::Versioned::Inline::Upgrade qw/before after/;

before '0.002' => sub {
    my $schema = shift;
    my $rset = $schema->resultset('Foo')->search({ height => undef});
    $rset->update({ height => 20});
    return 1;
};

after '0.002' => sub {
    print "foo\n";
    return 1;
};

before '0.004' => sub {
    return 1;
};

after '0.005' => sub {
    return 1;
};

1;
