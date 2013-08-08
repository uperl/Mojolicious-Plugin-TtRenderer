use Mojolicious::Lite;

# Documentation browser under "/perldoc"
plugin 'tt_renderer';

get '/' => sub {
  my $self = shift;
  $self->render('index');
};

app->start;

__DATA__

@@ index.html.tt
[% 
   WRAPPER 'layouts/default.html.tt' 
   title = 'default'
%]
<p>Welcome to the Mojolicious real-time web framework!</p>
<p>Welcome to the TtRenderer plugin!</p>
[% END %]

@@ layouts/default.html.tt
<!DOCTYPE html>
<html>
  <head><title>[% title %]</title></head>
  <body>[% content %]</body>
</html>
