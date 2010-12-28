#!/usr/bin/env perl

use strict;
use warnings;

use utf8;

use Test::More tests => 25;

use Mojolicious::Lite;
use Mojo::ByteStream 'b';
use Test::Mojo;

# Silence
app->log->level('fatal');

use_ok('MojoX::Renderer::TT');

plugin 'tt_renderer' => {template_options => {PRE_CHOMP => 1, POST_CHOMP => 1, TRIM => 1}};

get '/exception' => 'error';

get '/with_include' => 'include';

get '/with_wrapper' => 'wrapper';

#get '/with_auto_wrapper' => sub { shift->render(auto_wrapper => layout => 'layout') };

get '/unicode' => 'unicode';

get '/helpers' => 'helpers';

get '/unknown_helper' => 'unknown_helper';

get '/on-disk' => 'foo';

get '/foo/:message' => 'message';

get '/inline' => sub { shift->render(inline => '[% 1 + 1 %]', handler => 'tt') };

my $t = Test::Mojo->new;

# Exception
$t->get_ok('/exception')->status_is(500)->content_like(qr/error/i);

# Normal rendering
$t->get_ok('/foo/hello')->content_is("hello");

# With include
$t->get_ok('/with_include')->content_is("HelloInclude!Hallo");

# With wrapper
$t->get_ok('/with_wrapper')->content_is("wrapped");

# With auto wrapper
#$t->get_ok('/with_auto_wrapper')->content_is("wrapped");

# Unicode
$t->get_ok('/unicode')->content_is(b("привет")->encode('UTF-8')->to_string);

# Helpers
$t->get_ok('/helpers')->content_is("/helpers");

# Unknown helper
$t->get_ok('/unknown_helper')->status_is(500)->content_like(qr//);

# On Disk
$t->get_ok('/on-disk')->content_is("4");

# Not found
$t->get_ok('/not_found')->status_is(404)->content_like(qr/not found/i);

# Inline
$t->get_ok('/inline')->status_is(200)->content_is('2');

__DATA__

@@ message.html.tt
[% message %]

@@ error.html.tt
[% 1 + % %]

@@ include.inc
Hello

@@ includes/include.inc
Hallo

@@ include.html.tt
[%- INCLUDE 'include.inc' -%]
Include!
[% INCLUDE 'includes/include.inc' -%]

@@ layouts/layout.html.tt
w[%- content -%]d

@@ wrapper.html.tt
[%- WRAPPER 'layouts/layout.html.tt' -%]
rappe
[%- END -%]

@@ auto_wrapper.html.tt
rappe

@@ unicode.html.tt
привет

@@ helpers.html.tt
[% h.url_for('helpers') %]

@@ unknown_helper.html.tt
[% h.unknown_helper('foo') %]
