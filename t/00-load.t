#!perl

use Test::More tests => 2;

BEGIN {
	use_ok( 'Mojolicious::Plugin::TtRenderer' );
	use_ok( 'Mojolicious::Plugin::TtRenderer::Engine' );
}

diag( "Testing Mojolicious::Plugin::TtRenderer::Engine $Mojolicious::Plugin::TtRenderer::Engine::VERSION, Perl $], $^X" );
