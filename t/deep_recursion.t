#!/usr/bin/env perl

use strict;
use warnings;

#BEGIN { $ENV{MOJO_MODE}='testing'; };

use utf8;

use Test::More tests => 3;

use Mojolicious::Lite;
use Test::Mojo;

# Silence
app->log->level('fatal');

plugin 'tt_renderer';

get '/exception' => sub { die };

#say app->mode;
#app->start;
#exit;

my $t = Test::Mojo->new;

$t->app->renderer->default_handler('tt');

my $deep_recursion = 0;

do {
  local $SIG{__WARN__} = sub {
    my $warning = shift;
    if($warning =~ /Deep recursion/) {
      $deep_recursion = 1;
      die $warning;
    }
  };
  $t->get_ok('/exception')
    ->status_is(500);
};

ok !$deep_recursion, 'no deep recursion';

__DATA__

@@ exception.development.html.tt
[% 1 + % %]

@@ exception.html.tt
[% 1 + % %]

@@ exception.testing.html.tt
[% 1 + % %]
