#!perl

use Test::More tests => 2;

BEGIN {
	use_ok( 'Mojolicious::Plugin::TtRenderer' );
	use_ok( 'Mojolicious::Plugin::TtRenderer::Engine' );
}

