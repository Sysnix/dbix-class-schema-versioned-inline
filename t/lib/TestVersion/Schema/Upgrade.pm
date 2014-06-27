package TestVersion::Schema::Upgrade;

use base 'DBIx::Class::Schema::Versioned::Inline::Upgrade';
#use DBIx::Class::Schema::Versioned::Inline::Upgrade;
use DBIx::Class::Schema::Versioned::Inline::Upgrade qw/before after/;

before '0.002' => sub {
};

after '0.002' => sub {
    print "foo\n";
};

before '0.004' => sub {
};

after '0.005' => sub {
};

1;
