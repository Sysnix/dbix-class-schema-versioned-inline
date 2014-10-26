use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME               => 'DBIx::Class::Schema::Versioned::Inline',
    AUTHOR             => q{Peter Mottram (SysPete) <peter@sysnix.com>},
    VERSION_FROM       => 'lib/DBIx/Class/Schema/Versioned/Inline.pm',
    ABSTRACT           => 'Schema versioning for DBIx::Class with version information embedded inline in the schema definition.',
    LICENSE            => 'perl',
    PL_FILES           => {},
    MIN_PERL_VERSION   => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Class::Load'                 => 0,
        'DBIx::Class::Schema::Loader' => 0.07040,
        'File::Spec'                  => 3.47,
        'DBD::SQLite'                 => 1.40,
        'Test::Deep'                  => 0,
        'Test::Exception'             => 0,
        'Test::Roo'                   => 1.003,
        'Test::Warnings'              => 0.012,
    },
    PREREQ_PM => {
        'DBIx::Class'     => 0.08270,
        'SQL::Translator' => 0.11020,
        'Try::Tiny'       => 0.18,
        'version'         => 0.9902,
    },
    dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'DBIx-Class-Schema-Versioned-Inline-*' },
    META_MERGE => {
        resources => {
            repository => 'https://github.com/Sysnix/dbix-class-schema-versioned-inline.git',
            bugtracker => 'https://github.com/Sysnix/dbix-class-schema-versioned-inline/issues',
            IRC        => 'irc://irc.perl.org/#dbix-class',
        },
    },
);
