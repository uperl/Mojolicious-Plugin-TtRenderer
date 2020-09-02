# Mojolicious::Plugin::TtRenderer [![Build Status](https://travis-ci.org/plicease/Mojolicious-Plugin-TtRenderer.svg)](http://travis-ci.org/plicease/Mojolicious-Plugin-TtRenderer) [![Build status](https://ci.appveyor.com/api/projects/status/7suqp31y8k5eyif6/branch/master?svg=true)](https://ci.appveyor.com/project/plicease/Mojolicious-Plugin-TtRenderer/branch/master)

Template Renderer Plugin for Mojolicious

# SYNOPSIS

[Mojolicious::Lite](https://metacpan.org/pod/Mojolicious::Lite):

```
plugin 'tt_renderer';
```

[Mojolicious](https://metacpan.org/pod/Mojolicious)

```perl
$self->plugin('tt_renderer');
```

# DESCRIPTION

This plugin is a simple Template Toolkit renderer for [Mojolicious](https://metacpan.org/pod/Mojolicious).
Its defaults are usually reasonable, although for finer grain detail in
configuration you may want to use
[Mojolicious::Plugin::TtRenderer::Engine](https://metacpan.org/pod/Mojolicious::Plugin::TtRenderer::Engine) directly.

# OPTIONS

These are the options that can be passed in as arguments to this plugin.

## template\_options

Configuration hash passed into [Template](https://metacpan.org/pod/Template)'s constructor, see
[Template Toolkit's configuration summary](https://metacpan.org/pod/Template#CONFIGURATION-SUMMARY)
for details.  Here is an example using the [Mojolicious::Lite](https://metacpan.org/pod/Mojolicious::Lite) form:

```perl
plugin 'tt_renderer' => {
  template_options => {
    PRE_CHOMP => 1,
    POST_CHOMP => 1,
    TRIM => 1,
  },
};
```

Here is the same example using the full [Mojolicious](https://metacpan.org/pod/Mojolicious) app form:

```perl
package MyApp;

use Mojo::Base qw( Mojolicious );

sub startup {
  my($self) = @_;

  $self->plugin('tt_renderer' => {
    template_options => {
      PRE_CHOMP => 1,
      POST_CHOMP => 1,
      TRIM => 1,
    },
  }

  ...
}
```

These options will be used if you do not override them:

- INCLUDE\_PATH

    Generated based on your application's renderer's configuration.  It
    will include all renderer paths, in addition to search files located
    in the `__DATA__` section by the usual logic used by [Mojolicious](https://metacpan.org/pod/Mojolicious).

- COMPILE\_EXT

    `.ttc`

- UNICODE

    `1` (true)

- ENCODING

    `utf-87`

- CACHE\_SIZE

    `128`

- RELATIVE

    `1` (true)

## cache\_dir

Specifies the directory in which compiled template files are
written.  This:

```perl
plugin 'tt_renderer', { cache_dir => 'some/path' };
```

is equivalent to

```perl
plugin 'tt_renderer', { template_options { COMPILE_DIR => 'some/path' } };
```

except in the first example relative paths are relative to the [Mojolicious](https://metacpan.org/pod/Mojolicious)
app's home directory (`$app->home`).

# STASH

## h

Helpers are available via the `h` entry in the stash.

```
<a href="[% h.url_for('index') %]">go back to index</a>
```

## c

The current controller instance can be accessed as `c`.

```
I see you are requesting a document from [% c.req.headers.host %].
```

# EXAMPLES

[Mojolicious::Lite](https://metacpan.org/pod/Mojolicious::Lite) example:

```perl
use Mojolicious::Lite;

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
   title = 'Welcome'
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
```

[Mojolicious](https://metacpan.org/pod/Mojolicious) example:

```perl
package MyApp;
use Mojo::Base 'Mojolicious';

sub startup {
  my $self = shift;
  $self->plugin('tt_renderer');
  my $r = $self->routes;
  $r->get('/')->to('example#welcome');
}

1;

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
```

These are also included with the `Mojolicious::Plugin::TtRenderer`
distribution, including the support files required for the full
[Mojolicious](https://metacpan.org/pod/Mojolicious) app example.

# SEE ALSO

[Mojolicious::Plugin::TtRenderer::Engine](https://metacpan.org/pod/Mojolicious::Plugin::TtRenderer::Engine),
[Mojolicious](https://metacpan.org/pod/Mojolicious),
[Mojolicious::Guides](https://metacpan.org/pod/Mojolicious::Guides),
[http://mojolicious.org](http://mojolicious.org).

# AUTHOR

Original author: Ask Bjørn Hansen

Current maintainer: Graham Ollis <plicease@cpan.org>

Contributors:

vti

Marcus Ramberg

Matthias Bethke

Htbaa

Magnus Holm

Maxim Vuets

Rafael Kitover

giftnuss

Cosimo Streppone

Fayland Lam

Jason Crowther

spleenjack

Árpád Szász

Сергей Романов

uwisser

Dinis Lage

jay mortensen (GMORTEN)

Matthew Lawrence (MATTLAW)

# COPYRIGHT AND LICENSE

This software is copyright (c) 2009-2018 by Ask Bjørn Hansen.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
