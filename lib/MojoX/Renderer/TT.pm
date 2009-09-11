package MojoX::Renderer::TT;

use warnings;
use strict;
use base 'Mojo::Base';

use Template ();
use Carp     ();
use File::Spec ();

our $VERSION = '0.31';

__PACKAGE__->attr('tt');

sub build {
    my $self = shift->SUPER::new(@_);
    $self->_init(@_);
    return sub { $self->_render(@_) }
}

sub _init {
    my $self = shift;
    my %args = @_;

    my $mojo = delete $args{mojo};

    my $dir = $mojo && $mojo->home->rel_dir('tmp/ctpl');

    # TODO
    #   take and process options :-)

    my %config = (
        ( $mojo ? (INCLUDE_PATH => $mojo->home->rel_dir('templates') ) : () ),
        COMPILE_EXT => '.ttc',
        COMPILE_DIR => ($dir || File::Spec->tmpdir),
        UNICODE     => 1,
        ENCODING    => 'utf-8',
        CACHE_SIZE  => 128,
        RELATIVE    => 1,
        ABSOLUTE    => 1,
        %{$args{template_options} || {}},
    );

    $self->tt(Template->new(\%config))
      or Carp::croak "Could not initialize Template object: $Template::ERROR";

    return $self;
}

sub _render {
    my ($self, $renderer, $c, $output, $options) = @_;

    my $template_path;
    unless($template_path = $c->stash->{'template_path'}) {
        $template_path = $renderer->template_path($options);
    }

    unless (
        $self->tt->process(
            $template_path, {%{$c->stash}, c => $c},
            $output, {binmode => ":utf8"}
        )
      )
    {
        Carp::carp $self->tt->error . "\n";
        return 0;
    }
    else {
        return 1;
    }
}


1;    # End of MojoX::Renderer::TT

__END__

=encoding utf-8

=head1 NAME

MojoX::Renderer::TT - Template Toolkit renderer for Mojo

=head1 SYNOPSIS

Add the handler:

    use MojoX::Renderer::TT;

    sub startup {
       ...

       my $tt = MojoX::Renderer::TT->build(
            mojo => $self,
            template_options =>
             { PROCESS => 'tpl/wrapper',
               FILTERS => [ foo => [ \&filter_factory, 1]
             }
       );

       $self->renderer->add_handler( html => $tt );
    }

And then in the handler call render which will call the
MojoX::Renderer::TT renderer.

   $c->render(templatename, format => 'tex', handler => 'tt2');

Template parameter are taken from $c->stash

=head1 METHODS

=head2 build

This method returns a handler for the Mojolicious renderer.

Supported parameters are

=over 4

=item mojo
C<build> currently uses a C<mojo> parameter pointing to the base class (Mojo).
object. When used the INCLUDE_PATH will be set to 

=item template_options

A hash reference of options that are passed to Template->new(). 

=back


=head1 AUTHOR

Ask Bjørn Hansen, C<< <ask at develooper.com> >>

=head1 TODO

   * Better support non-Mojolicious frameworks
   * Move the default template cache directory?
   * Better way to pass parameters to the templates? (stash)
   * More sophisticated default search path?

=head1 BUGS

Please report any bugs or feature requests to C<bug-mojox-renderer-tt at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MojoX-Renderer-TT>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MojoX::Renderer::TT

You can also look for information at:

=over 4

=item * git repository

L<http://git.develooper.com/?p=MojoX-Renderer-TT.git;a=summary>,
L<git://git.develooper.com/MojoX-Renderer-TT.git>

L<http://github.com/abh/mojox-renderer-tt/>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MojoX-Renderer-TT>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MojoX-Renderer-TT>

=item * Search CPAN

L<http://search.cpan.org/dist/MojoX-Renderer-TT/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008-2009 Ask Bjørn Hansen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut
