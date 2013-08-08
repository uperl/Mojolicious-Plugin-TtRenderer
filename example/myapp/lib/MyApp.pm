package MyApp;
use Mojo::Base 'Mojolicious';

sub startup {
  my $self = shift;
  $self->plugin('tt_renderer');
  my $r = $self->routes;
  $r->get('/')->to('example#welcome');
}

1;
