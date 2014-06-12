use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME               => 'DBIx::Class::Schema::Versioned::Jiftyesque',
    AUTHOR             => q{Peter Mottram (SysPete) <peter@sysnix.com>},
    VERSION_FROM       => 'lib/DBIx/Class/Schema/Versioned/Jiftyesque.pm',
    ABSTRACT_FROM      => 'lib/DBIx/Class/Schema/Versioned/Jiftyesque.pm',
    LICENSE            => 'perl',
    PL_FILES           => {},
    MIN_PERL_VERSION   => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Class::Unload'       => 0.08,
        'DBICx::TestDatabase' => 0.05,
        'File::Spec'          => 0,
        'File::Temp'          => 0,
        'Test::More'          => 0,
        'Test::Most'          => 0,
    },
    PREREQ_PM => {
#        'Moo'              => 1.004006,
#        'MooX::HandlesVia' => 0.001005,
#        'namespace::clean' => 0.25,
#        'Type::Tiny'       => 0.042,
        'version' => 0.9902,
    },
    dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'DBIx-Class-Schema-Versioned-Jiftyesque-*' },
);
