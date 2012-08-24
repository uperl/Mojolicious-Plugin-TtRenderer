#!/usr/bin/env perl

use strict;
use warnings;

BEGIN { $ENV{MOJO_MODE} = 'testing' };

use utf8;

use Test::More tests => 7;

use Mojolicious::Lite;
use Test::Mojo;
use File::Temp qw( tempdir );

use FindBin ();
use lib "$FindBin::Bin/templates";

use_ok 'Foo';

push @{app->renderer->classes}, 'Foo';

plugin 'tt_renderer' => {template_options => {PRE_CHOMP => 1, POST_CHOMP => 1, TRIM => 1}};

app->log->level('fatal'); 

get '/with_include' => 'include';
get '/with_wrapper' => 'wrapper';

my $t = Test::Mojo->new;

# With include
$t->get_ok('/with_include')->status_is(200)->content_is("HelloInclude!Hallo");

# With wrapper
$t->get_ok('/with_wrapper')->status_is(200)->content_is("wrapped");

__DATA__

@@ wrapper.html.tt
[%- WRAPPER 'layouts/layout.html.tt' -%]
rappe
[%- END -%]

@@ include.html.tt 
[%- INCLUDE 'include.inc' -%]
Include!
[%- INCLUDE 'includes/sub/include.inc' -%]
