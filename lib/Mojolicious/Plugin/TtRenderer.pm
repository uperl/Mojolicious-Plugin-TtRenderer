package Mojolicious::Plugin::TtRenderer;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use Mojolicious::Plugin::TtRenderer::Engine;

sub register {
    my ($self, $app, $args) = @_;

    $args ||= {};

    my $tt = Mojolicious::Plugin::TtRenderer::Engine->build(%$args, app => $app);

    # Add "tt" handler
    $app->renderer->add_handler(tt => $tt);
}

local ($Mojolicious::Plugin::TtRenderer::VERSION) = ('devel') unless defined $Mojolicious::Plugin::TtRenderer::VERSION;

1;
__END__

=head1 NAME

Mojolicious::Plugin::TtRenderer - Template Renderer Plugin

=head1 SYNOPSIS

    # Mojolicious
    $self->plugin('tt_renderer');
    $self->plugin(tt_renderer => {template_options => {FILTERS => [ ... ]}});

    # Mojolicious::Lite
    plugin 'tt_renderer';
    plugin tt_renderer => {template_options => {FILTERS => [ ... ]}};

=head1 DESCRIPTION

L<Mojolicous::Plugin::TtRenderer> is a simple loader for L<MojoX::Renderer::TT>.

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

L<Mojolicious::Plugin::TtRenderer::Engine>, L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicious.org>.

=cut
