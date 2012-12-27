use strict;
use warnings;
use Test::More tests => 3;
use Test::Mojo;
use File::Temp qw( tempdir );

use Mojolicious::Lite;

# Tell Mojolicious we want to load the TT renderer plugin
app->plugin(
    tt_renderer => {
        template_options => {
            # These options are specific to TT
            INCLUDE_PATH => 'templates',
            COMPILE_DIR  => tempdir( CLEANUP => 1 ),
            COMPILE_EXT  => '.ttc',
            # ... anything else to be passed on to TT should go here
        },
    }
);

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
