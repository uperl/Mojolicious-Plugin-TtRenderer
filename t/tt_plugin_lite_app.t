#!/usr/bin/env perl

# Copyright (C) 2008-2010, Sebastian Riedel.

use strict;
use warnings;

use File::Temp;
use Mojo::IOLoop;
use Test::More;

# Use a clean temporary directory
BEGIN { $ENV{MOJO_TMPDIR} ||= File::Temp::tempdir }

# Make sure sockets are working
plan skip_all => 'working sockets required for this test!'
  unless Mojo::IOLoop->new->generate_port;
plan tests => 6;

# Leela: OK, this has gotta stop. I'm going to remind Fry of his humanity the way only a woman can.
# Farnsworth: You're going to do his laundry?

use Mojolicious::Lite;
use Test::Mojo;

# POD renderer plugin
plugin 'tt_renderer';

# Silence
app->log->level('error');

# GET /
get '/'     => 'index';
get '/blow' => sub {
    shift->render(template => 'conditional-exception', do_process => 1);
};


my $t = Test::Mojo->new;

# Simple TT template
$t->get_ok('/')->status_is(200)
  ->content_like(qr/test123456/);
$t->get_ok('/blow')->status_is(500)->content_like(qr/file error - doesnotexist.tt: not found/);

if(eval q{ use Devel::Cycle; 1 })
{
  Devel::Cycle::find_cycle(app, sub {
    my $arg = shift;
    # Template::Provider (from which M::P::T::Provider inherits) has some cycles which are freed manaully by
    # its DESTROY method, so we skip reporting those cycles.
    unless(scalar(scalar(grep { ref($_->[2]) eq 'Mojolicious::Plugin::TtRenderer::Provider' && $_->[1] =~ /^(HEAD|TAIL|LOOKUP)$/ } @$arg)) > 0)
    {
      #use YAML ();
      #diag YAML::Dump([ map { [ $_->[0], $_->[1], ref($_->[2]), ref($_->[3]) ] } @$arg ]);
      fail('Cycle found')
    }
  });
};
