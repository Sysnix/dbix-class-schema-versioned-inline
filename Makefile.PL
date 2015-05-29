use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;


WriteMakefile(
    NAME               => 'DBIx::Class::Schema::Versioned::Inline',
    AUTHOR             => q{Peter Mottram (SysPete) <peter@sysnix.com>},
    VERSION_FROM       => 'lib/DBIx/Class/Schema/Versioned/Inline.pm',
    ABSTRACT_FROM      => 'lib/DBIx/Class/Schema/Versioned/Inline.pm',
    LICENSE            => 'perl',
    PL_FILES           => {},
    MIN_PERL_VERSION   => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Class::Load'                 => 0,
        'DBD::SQLite'                 => '1.40',
        'DBIx::Class::Schema::Loader' => '0.07040',
        'File::Spec'                  => '3.47',
        'Test::Deep'                  => 0,
        'Test::Exception'             => 0,
        'Test::Roo'                   => '1.003',
    },
    PREREQ_PM => {
        'DBIx::Class'        => '0.082820',
        'Safe::Isa'          => 0,
        'Set::Equivalence'   => '0.003',
        'Try::Tiny'          => '0.18',
        'Types::PerlVersion' => '0.002',
        'SQL::Translator'    => '0.11021',
    },
    dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean      => { FILES => 'DBIx-Class-Schema-Versioned-Inline-*' },
    META_MERGE => {
        resources => {
#<<<
            repository => {
                type => 'git',
                url  => 'git://github.com/Sysnix/dbix-class-schema-versioned-inline.git',
                web  => 'https://github.com/Sysnix/dbix-class-schema-versioned-inline',
            },
            bugtracker => {
                web => 'https://github.com/Sysnix/dbix-class-schema-versioned-inline/issues',
            },
            IRC => 'irc://irc.perl.org/#dbix-class',
#>>>
        },
    },
);
