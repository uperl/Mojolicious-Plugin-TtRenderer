#!/usr/bin/env perl

use strict;
use warnings;
use 5.016;

BEGIN { $ENV{MOJO_MODE}='testing'; };

use utf8;

use Test::More tests => 3;

use Mojolicious::Lite;
use Mojo::ByteStream 'b';
use Test::Mojo;
use File::Temp qw( tempdir );

# Silence
app->log->level('fatal');

use_ok('Mojolicious::Plugin::TtRenderer::Engine');

plugin 'tt_renderer' => {template_options => {PRE_CHOMP => 1, POST_CHOMP => 1, TRIM => 1, COMPILE_DIR => tempdir( CLEANUP => 1 ) }};
app->defaults(layout => 'wrapper');

get '/test' => 'test';

my $t = Test::Mojo->new;

$t->get_ok('/test')->content_is("WS-hello-EW");

__DATA__

@@ test.html.tt
hello

@@ layouts/wrapper.html.tt
WS-[%- content -%]-EW
