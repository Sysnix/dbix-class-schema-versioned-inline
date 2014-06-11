package TestVersion::Schema::Upgrade;
use base 'DBIx::Class::Schema::Versioned::Jiftyesque::Upgrade';
use DBIx::Class::Schema::Versioned::Jiftyesque::Upgrade qw(since rename);
use strict;
use warnings;

since '0.004' => sub {
};

since '0.005' => sub {
};

1;
