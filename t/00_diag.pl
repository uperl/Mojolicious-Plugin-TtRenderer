use strict;
use warnings;
use Test::More;
use Mojo::IOLoop;

our $format;

my $loop = eval { Mojo::IOLoop->singleton };
diag $@ if $@;
diag sprintf $format, 'mojo io loop', ref eval { $loop->reactor };
diag $@ if $@;

1;
