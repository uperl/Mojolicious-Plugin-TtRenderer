package MyApp::Example;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub welcome {
  my $self = shift;

  # Render template "example/welcome.html.tt" with message
  $self->render(
    message => 'Looks like your TtRenderer is working!');
}

1;
