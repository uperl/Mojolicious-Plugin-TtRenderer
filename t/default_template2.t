use strict;
use warnings;
use Test::More tests => 9;
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
        #INCLUDE_PATH => "$Bin/templates",
        COMPILE_DIR  => tempdir( CLEANUP => 1 ),
    }
);

app->renderer->add_handler(tt => $tt);
app->renderer->default_handler('tt');

get '/' => sub {
    die 'foo';
};

get '/bar' => 'bar';

get '/grimlock' => 'grimlock';

my $t = Test::Mojo->new;

$t->get_ok('/')
    ->status_is(500)
    ->content_like(qr{foo});

$t->get_ok('/bar')
    ->status_is(200)
    ->content_like(qr{bar});

$t->get_ok('/grimlock')
    ->status_is(200)
    ->content_like(qr{King});

__DATA__

@@ index.html.tt
anything

@@ bar.html.tt
sometimes, the bar, he eats you...
