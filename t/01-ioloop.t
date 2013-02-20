use strict;
use warnings;
use Test::More tests => 1;
use Mojo::IOLoop;

my $loop = eval { Mojo::IOLoop->singleton };
diag $@ if $@;
ok $loop;
diag ref eval { $loop->reactor };
diag $@ if $@;

