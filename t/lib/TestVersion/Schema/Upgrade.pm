package TestVersion::Schema::Upgrade;
use base 'DBIx::Class::Schema::Versioned::Inline::Upgrade';
use DBIx::Class::Schema::Versioned::Inline::Upgrade qw/since/;
use strict;
use warnings;

since '0.002' => sub {
    print "foo\n";
};

since '0.004' => sub {
};

since '0.005' => sub {
};

1;
