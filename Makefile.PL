use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    ABSTRACT => 'Template Toolkit renderer for Mojo',
    AUTHOR => 'Ask Bjorn Hansen <ask@develooper.com>',
    DISTNAME => 'MojoX-Renderer-TT',
    NAME => 'MojoX::Renderer::TT',
    VERSION_FROM => 'lib/MojoX/Renderer/TT.pm',
    ABSTRACT_FROM => 'lib/MojoX/Renderer/TT.pm',
    LICENSE => 'perl',
    PREREQ_PM => {
        'Test::More' => 0,
        'Mojolicious' => 0.999926,
        'Template' => 2.18,
    },
    dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'MojoX-Renderer-TT-*' },
    test => {
        'TESTS' => 't/*.t',
    },
);
