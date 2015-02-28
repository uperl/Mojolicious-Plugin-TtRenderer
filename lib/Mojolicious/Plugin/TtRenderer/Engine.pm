package Mojolicious::Plugin::TtRenderer::Engine;

use warnings;
use strict;
use v5.10;
use base 'Mojo::Base';
use Carp ();
use File::Spec ();
use Mojo::ByteStream 'b';
use Template ();
use Cwd qw/abs_path/;
use Scalar::Util 'weaken';
use POSIX ':errno_h';

# ABSTRACT: Template Toolkit renderer for Mojolicious
# VERSION

__PACKAGE__->attr('tt');

sub build {
    my $self = shift->SUPER::new(@_);
    weaken($self->{app});
    $self->_init(@_);
    return sub { $self->_render(@_) }
}

sub _init {
    my $self = shift;
    my %args = @_;

    #$Template::Parser::DEBUG = 1;

    my $dir;
    my $app = delete $args{mojo} || delete $args{app};
    if($dir=$args{cache_dir}) {

      if($app && substr($dir,0,1) ne '/') {
        $dir=$app->home->rel_dir($dir);
      }
    }

    # TODO
    #   take and process options :-)

    my @renderer_paths = $app ? map { abs_path($_) } grep { -d $_ } @{ $app->renderer->paths } : ();
    push @renderer_paths, 'templates';

    my %config = (
        INCLUDE_PATH => \@renderer_paths,
        COMPILE_EXT  => '.ttc',
        UNICODE      => 1,
        ENCODING     => 'utf-8',
        CACHE_SIZE   => 128,
        RELATIVE     => 1,
        %{$args{template_options} || {}},
    );

    $config{COMPILE_DIR} //= $dir || do {
      my $tmpdir = File::Spec->catdir(File::Spec->tmpdir, "ttr$<");
      mkdir $tmpdir unless -d $tmpdir;
      $tmpdir;
    };

    $config{LOAD_TEMPLATES} =
      [Mojolicious::Plugin::TtRenderer::Provider->new(%config, renderer => $app->renderer)]
      unless $config{LOAD_TEMPLATES};

    $self->tt(Template->new(\%config))
      or Carp::croak "Could not initialize Template object: $Template::ERROR";

    return $self;
}

sub _render {
    my ($self, $renderer, $c, $output, $options) = @_;

    # Inline
    my $inline = $options->{inline};

    # Template
    my $t = $renderer->template_name($options);
    $t = 'inline' if defined $inline;
    return unless $t;

    my $helper = Mojolicious::Plugin::TtRenderer::Helper->new(ctx => $c);

    # Purge previous result
    $$output = '';

    # fixes for t/lite_app_with_default_layouts.t
    unless ($c->stash->{layout}) {
        $c->stash->{content} ||= $c->stash->{'mojo.content'}->{content};
    }

    my @params = ({%{$c->stash}, c => $c, h => $helper}, $output, {binmode => ':utf8'});
    my $provider = $self->tt->{SERVICE}->{CONTEXT}->{LOAD_TEMPLATES}->[0];
    $provider->options($options);
    $provider->ctx($c);

    my $ok = do {
        if (defined $inline) {
            $self->tt->process(\$inline, @params);
        }
        else {
            my @ret = $provider->fetch($t);

            if (not defined $ret[1]) {
                $self->tt->process($ret[0], @params);
            }
            elsif (not defined $ret[0]) { # not found
                return 0;
            }
            else { # error
                return 0 if $! == ENOENT && (not ref $ret[0]); # not found when not blessed exception
                die $ret[0];
            }
        }
    };

    # Error
    die $self->tt->error unless $ok;

    return 1;
}

1;    # End of Mojolicious::Plugin::TtRenderer::Engine

package
  Mojolicious::Plugin::TtRenderer::Helper;

use strict;
use warnings;

use base 'Mojo::Base';

our $AUTOLOAD;

__PACKAGE__->attr('ctx');

sub AUTOLOAD {
    my $self = shift;

    my $method = $AUTOLOAD;

    return if $method =~ /^[A-Z]+?$/;
    return if $method =~ /^_/;
    return if $method =~ /(?:\:*?)DESTROY$/;

    $method = (split '::' => $method)[-1];

    die qq/Unknown helper: $method/ unless $self->ctx->app->renderer->helpers->{$method};

    return $self->ctx->$method(@_);
}

1;

package
  Mojolicious::Plugin::TtRenderer::Provider;

use strict;
use warnings;

use base 'Template::Provider';
use Scalar::Util 'weaken';

sub new {
    my $class = shift;
    my %params = @_;

    my $renderer = delete $params{renderer};

    my $self = $class->SUPER::new(%params);
    $self->renderer($renderer);
    weaken($self->{renderer});
    return $self;
}

sub renderer      { @_ > 1 ? $_[0]->{renderer}      = $_[1] : $_[0]->{renderer} }
sub ctx           { @_ > 1 ? $_[0]->{ctx}           = $_[1] : $_[0]->{ctx} }
sub options       { @_ > 1 ? $_[0]->{options}       = $_[1] : $_[0]->{options} }

sub _template_modified {
    my($self, $template) = @_;
    $self->SUPER::_template_modified($template) || $template =~ /^templates(?:\/|\\)/;
}

sub _template_content {
    my $self = shift;
    my ($path) = @_;

    my $options = delete $self->{options};
    
    # Convert backslashes to forward slashes to make inline templates work on Windows
    $path =~ s/\\/\//g;
    my ($t) = ($path =~ m{templates\/(.*)$});
    
    if (-r $path) {
        return $self->SUPER::_template_content(@_);
    }

    my $data;
    my $error = '';

    # Try DATA section
    if(defined $options) {
        $data = $self->renderer->get_data_template($options);
    } else {
        foreach my $class (@{ $self->renderer->classes }) {
            $data = Mojo::Loader::data_section($class, $t);
            last if $data;
        }
    }

    unless($data) {
        $data = '';
        $error = "$path: not found";
    }
    return wantarray ? ($data, $error, time) : $data;
}

1;

__END__

=encoding utf-8

=begin stopwords

Bjørn
Szász
Árpád

=end stopwords

=head1 SYNOPSIS

Add the handler:

 sub startup {
     ...
 
     # Via mojolicious plugin
     $self->plugin(tt_renderer => {template_options => {FILTERS => [ ... ]}});
 
     # Or manually
     use Mojolicious::Plugin::TtRenderer::Engine;
 
     my $tt = Mojolicious::Plugin::TtRenderer::Engine->build(
         mojo => $self,
         template_options => {
             PROCESS  => 'tpl/wrapper',
             FILTERS  => [ ... ],
             UNICODE  => 1,
             ENCODING => 'UTF-8',
         }
     );

     $self->renderer->add_handler( tt => $tt );
 }

Template parameter are taken from C<$c-E<gt>stash>.

=head1 DESCRIPTION

See L<Mojolicious::Plugin::TtRenderer> for details on the plugin interface to this module.

This module provides an engine for the rendering of L<Template Toolkit|Template> templates
within a Mojolicious context.  Templates may be, stored on the local file system, provided
inline by the controller or included in the C<__DATA__> section.  Where possible this modules
attempts to provide a TT analogue interface to the L<Perlish templates|Mojo::Template> which 
come with Mojolicious.

=head1 RENDERING

The template file for C<"example/welcome"> would be C<"templates/welcome.html.tt">.

When template file is not available rendering from C<__DATA__> is attempted.

 __DATA__

 @@ welcome.html.tt
 Welcome, [% user.name %]!

Inline template is also supported:

 $self->render(inline => '[% 1 + 1 %]', handler => 'tt');

=head1 HELPERS

Helpers are exported automatically under C<h> namespace.

 [% h.url_for('index') %]

=head1 METHODS

=head2 build

This method returns a handler for the Mojolicious renderer.

Supported parameters are

=over 4

=item mojo
C<build> currently uses a C<mojo> parameter pointing to the base class (Mojo).
object. When used the INCLUDE_PATH will be set to

=item template_options

A hash reference of options that are passed to Template->new().  Note that if you
specify an C<INCLUDE_PATH> through this option it will remove the DATA section
templates from your path.  A better way to specify an C<INCLUDE_PATH> if you also
want to use DATA section templates it by manipulating the L<Mojolicious::Renderer>
path.

=item cache_dir

Absolute or relative dir to your app home, to cache processed versions of your
templates. Will default to a temp-dir if not set.

=back

=head1 SEE ALSO

L<Mojolicious::Plugin::TtRenderer>, 
L<Mojolicious>, 
L<Mojolicious::Guides>, 
L<http://mojolicious.org>.

=cut
