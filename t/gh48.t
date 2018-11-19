use strict;
use warnings;
use Test::Mojo;
use Test::More;
use Mojolicious::Lite;

app->plugin('tt_renderer' => {
    template_options => {
        CONSTANTS => { foo => 123 },
    },
});

app->renderer->default_handler('tt');

get '/foo' => sub {
  shift->render( template => 'foox' );
};

my $t = Test::Mojo->new;

$t->get_ok('/foo')
  ->status_is(200)
  ->content_like(qr/Foo is 123/);

done_testing;

__DATA__

@@ foox.html.tt
Foo is "[% constants.foo %]"
