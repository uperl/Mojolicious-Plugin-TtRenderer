#!/usr/bin/env perl

use strict;
use warnings;

BEGIN { $ENV{MOJO_MODE}='testing'; };

use utf8;

use Test::More tests => 7;

use Mojolicious::Lite;
use Test::Mojo;

# Silence
app->log->level('fatal');

my @paths = map { app->home->rel_dir($_) } "templates/multiple_first", "templates/multiple_second";
app->renderer->paths([@paths]);

use_ok('Mojolicious::Plugin::TtRenderer::Engine');

plugin 'TtRenderer';

get '/first' => 'first';
get '/second' => 'second';

my $t = Test::Mojo->new;

$t->get_ok('/first')->status_is(200)->content_like(qr/First/);
$t->get_ok('/second')->status_is(200)->content_like(qr/Second/);

