package Mojolicious::Plugin::TtRenderer;

use strict;
use warnings;
use v5.10;

# ABSTRACT: Template Renderer Plugin for Mojolicious
# VERSION

use base 'Mojolicious::Plugin';

use Mojolicious::Plugin::TtRenderer::Engine;

sub register {
    my ($self, $app, $args) = @_;

    $args ||= {};

    my $tt = Mojolicious::Plugin::TtRenderer::Engine->build(%$args, app => $app);

    # Add "tt" handler
    $app->renderer->add_handler(tt => $tt);
}

$Mojolicious::Plugin::TtRenderer::VERSION //= ('devel');

1;
__END__

=encoding utf-8

=head1 SYNOPSIS

L<Mojolicious::Lite> example:

# EXAMPLE: example/myapp.pl

L<Mojolicious> example:

# EXAMPLE: example/myapp/lib/MyApp.pm

# EXAMPLE: example/myapp/lib/MyApp/Example.pm

=head1 DESCRIPTION

This plugin is a simple Template Toolkit renderer for L<Mojolicious>. 
Its defaults are usually reasonable, although for finer grain detail in 
configuration you may want to use 
L<Mojolicious::Plugin::TtRenderer::Engine> directly.

=head1 OPTIONS

These are the options that can be passed in as arguments to this plugin.

=head2 template_options

Configuration hash passed into L<Template>'s constructor, see 
L<Template Toolkit's configuration summary|Template#CONFIGURATION-SUMMARY>
for details.  Here is an example using the L<Mojolicious::Lite> form:

 plugin 'tt_renderer' => {
   template_options => {
     PRE_CHOMP => 1,
     POST_CHOMP => 1,
     TRIM => 1,
   },
 };

Here is the same example using the full L<Mojolicious> app form:

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

These options will be used if you do not override them:

=over 4

=item INCLUDE_PATH

Generated based on your application's renderer's configuration.  It
will include all renderer paths, in addition to search files located
in the C<__DATA__> section by the usual logic used by L<Mojolicious>.

=item COMPILE_EXT

C<.ttc>

=item UNICODE

C<1> (true)

=item ENCODING

C<utf-87>

=item CACHE_SIZE

C<128>

=item RELATIZE

C<1> (true)

=back

=head2 cache_dir

Specifies the directory in which compiled template files are
written.  This:

 plugin 'tt_renderer', { cache_dir => 'some/path' };

is equivalent to

 plugin 'tt_renderer', { template_options { COMPILE_DIR => 'some/path' } };

except in the first example relative paths are relative to the L<Mojolicious>
app's home directory (C<$app->home>).

=head1 METHODS

L<Mojolicious::Plugin::TtRenderer> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 C<register>

 $plugin->register;

Register renderer in L<Mojolicious> application.

=head1 EXTRA STASH VARIABLES

The current controller instance can be accessed as C<c>.

 [% c.req.headers.host %]

=head1 SEE ALSO

L<Mojolicious::Plugin::TtRenderer::Engine>, 
L<Mojolicious>, 
L<Mojolicious::Guides>, 
L<http://mojolicious.org>.

=cut
