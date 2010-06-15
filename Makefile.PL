use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'MojoX::Renderer::TT',
    AUTHOR              => 'Ask Bjørn Hansen <ask@develooper.com>',
    VERSION_FROM        => 'lib/MojoX/Renderer/TT.pm',
    ABSTRACT_FROM       => 'lib/MojoX/Renderer/TT.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'Mojo'       => 0.999926,
        'Template'   => 2.18,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'MojoX-Renderer-TT-*' },
);
