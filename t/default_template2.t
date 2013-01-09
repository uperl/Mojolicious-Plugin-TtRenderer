use strict;
use warnings;
use Test::More tests => 3;
use Test::Mojo;
use File::Temp qw( tempdir );
use FindBin '$Bin';

use Mojolicious::Lite;
use Mojolicious::Plugin::TtRenderer::Engine ();

my $tt = Mojolicious::Plugin::TtRenderer::Engine->build(
    mojo => app,
    template_options => {
        UNICODE  => 1,
        ENCODING => 'UTF-8',
        INCLUDE_PATH => "$Bin/templates",
    }
);

app->renderer->add_handler(tt => $tt);
app->renderer->default_handler('tt');

get '/' => sub {
    die 'foo';
};

my $t = Test::Mojo->new;

$t->get_ok('/')
    ->status_is(500)
    ->content_like(qr{foo});

__DATA__

@@ index.html.tt
anything
