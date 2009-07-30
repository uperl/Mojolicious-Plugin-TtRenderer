#!perl

use strict;
use warnings;

use Test::More tests => 5;

use Mojo::Transaction;
use MojoX::Context;

use_ok('MojoX::Renderer::TT');

my $c = MojoX::Context->new;

my $mt = MojoX::Renderer::TT->build;

my $output;
my $rv;

$c->stash->{template} = 't/render/template.tt2';

$rv = $mt->(undef, $c, \$output);
is($rv, 1);
is($output, "4\n");

$c->stash->{template} = 't/render/error.tt2';
$rv = $mt->(undef, $c, \$output);
is($rv, 0);
ok($output);
