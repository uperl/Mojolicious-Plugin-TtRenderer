#!/usr/bin/env perl

# Copyright (C) 2008-2010, Sebastian Riedel.

use strict;
use warnings;

BEGIN {
  unless($^O eq 'MSWin32') {
    eval '# line '. __LINE__ . ' "' . __FILE__ . qq("\n). q{
      use POSIX qw( setlocale LC_ALL );
      setlocale(LC_ALL, 'C');
    };
    warn $@ if $@;
  }
}

use File::Temp qw( tempdir );
use Mojo::IOLoop;
use Test::More;

# Use a clean temporary directory
BEGIN { $ENV{MOJO_TMPDIR} ||= tempdir( CLEANUP => 1) }

# Make sure sockets are working
plan skip_all => 'working sockets required for this test!'
  unless Mojo::IOLoop::Server->new->generate_port;
plan tests => 6;

# Leela: OK, this has gotta stop. I'm going to remind Fry of his humanity the way only a woman can.
# Farnsworth: You're going to do his laundry?

use Mojolicious::Lite;
use Test::Mojo;

# POD renderer plugin
plugin 'tt_renderer' => {template_options => { COMPILE_DIR => tempdir( CLEANUP => 1 ) }};

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
$t->get_ok('/blow')->status_is(500)->content_like(qr/file error - (templates\/)?doesnotexist\.tt: (No such file or directory|not found)/);

if(eval q{ use Devel::Cycle; 1 })
{
  # ignore warnings coming from Devel::Cycle
  local $SIG{__WARN__} = sub { };
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
