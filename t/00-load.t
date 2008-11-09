#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'MojoX::Renderer::TT' );
}

diag( "Testing MojoX::Renderer::TT $MojoX::Renderer::TT::VERSION, Perl $], $^X" );
