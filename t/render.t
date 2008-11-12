#!perl

use strict;
use warnings;

use Test::More tests => 5;

use Mojo::Transaction;

use_ok('MojoX::Renderer::TT');

my $mt = MojoX::Renderer::TT->build;

my $output;
my $rv;

$rv = $mt->(undef, 't/render/template.tt2', \$output);
is($rv, 1);
is($output, "4\n");

$rv = $mt->(undef, 't/render/template-error.tt2', \$output);
is($rv, 0);
ok($output);
