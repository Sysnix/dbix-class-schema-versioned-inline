use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'DBIx::Class::Schema::Versioned::Jiftyesque',
    AUTHOR           => q{Peter Mottram (SysPete) <peter@sysnix.com>},
    VERSION_FROM     => 'lib/DBIx/Class/Schema/Versioned/Jiftyesque.pm',
    ABSTRACT_FROM    => 'lib/DBIx/Class/Schema/Versioned/Jiftyesque.pm',
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'DBIx-Class-Schema-Versioned-Jiftyesque-*' },
);
