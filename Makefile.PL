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
        'DBIx::Class::Schema::Loader' => 0.07040,
        'Class::Unload'               => 0.08,
        'File::Spec'                  => 3.47,
        'Test::Most'                  => 0.33,
    },
    PREREQ_PM => {
        'DBIx::Class'     => 0.08270,
        'SQL::Translator' => 0.11018,
        'version'         => 0.9902,
    },
    dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'DBIx-Class-Schema-Versioned-Jiftyesque-*' },
);
