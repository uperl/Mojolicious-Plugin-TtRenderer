#!/usr/bin/env perl

use strict;
use warnings;

use utf8;

use Test::More tests => 22;

use Mojolicious::Lite;
use Mojo::ByteStream 'b';
use Test::Mojo;

# Silence
app->log->level('fatal');

use_ok('MojoX::Renderer::TT');

plugin 'tt_renderer';

get '/exception' => 'error';

get '/with_include' => 'include';

get '/with_wrapper' => 'wrapper';

get '/unicode' => 'unicode';

get '/helpers' => 'helpers';

get '/unknown_helper' => 'unknown_helper';

get '/on-disk' => 'foo';

get '/foo/:message' => 'index';

my $t = Test::Mojo->new;

# Exception
$t->get_ok('/exception')->status_is(500)->content_like(qr/error/i);

# Normal rendering
$t->get_ok('/foo/hello')->content_is("hello\n\n");

# With include
$t->get_ok('/with_include')->content_is("Hello\n\nInclude!\n\n");

# With wrapper
$t->get_ok('/with_wrapper')->content_is("wrapped\n\n\n");

# Unicode
$t->get_ok('/unicode')->content_is(b("привет")->encode('UTF-8')->to_string . "\n\n");

# Helpers
$t->get_ok('/helpers')->content_is("/helpers\n\n");

# Unknown helper
$t->get_ok('/unknown_helper')->status_is(500)->content_like(qr//);

# On Disk
$t->get_ok('/on-disk')->content_is("4\n");

# Not found
$t->get_ok('/not_found')->status_is(404)->content_like(qr/not found/i);

__DATA__

@@ index.html.tt
[% message %]

@@ error.html.tt
[% 1 + % %]

@@ include.inc
Hello

@@ include.html.tt
[% INCLUDE 'include.inc' -%]
Include!

@@ wrapper.html.tt
[%- WRAPPER 'layout.html.tt' -%]
rappe
[%- END -%]

@@ layout.html.tt
w[% content %]d

@@ unicode.html.tt
привет

@@ helpers.html.tt
[% h.url_for('helpers') %]

@@ unknown_helper.html.tt
[% h.unknown_helper('foo') %]
