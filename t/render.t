#!perl

use strict;
use warnings;

use Test::More tests => 6;

use Mojolicious;
use Mojolicious::Controller;
use MojoX::Renderer;

use_ok('MojoX::Renderer::TT');

my $c = Mojolicious::Controller->new(app => Mojolicious->new);
$c->app->log->path(undef);
$c->app->log->level('fatal');

my $mt = MojoX::Renderer::TT->build;

my $output;
my $rv;

$c->stash->{template_path} = 't/render/template.tt2';
$rv = $mt->(undef, $c, \$output);
is($rv, 1);
is($output, "4\n");

$c->stash->{template_path} = 't/render/error.tt2';
$rv = $mt->(undef, $c, \$output);
is($rv, 0);
ok($output);

delete $c->stash->{template_path};

$c->app->renderer->root('./')->add_handler(tt2 => $mt);

is($c->render('t/render/template','partial' => 1,handler => 'tt2'),"4\n");


