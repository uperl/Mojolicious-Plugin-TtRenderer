package MojoX::Renderer::TT;

use warnings;
use strict;
use base 'Mojo::Base';

use Template ();
use Carp ();

__PACKAGE__->attr('tt',
    chained => 1,
);


sub new {
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
        COMPILE_EXT => '.ttc',
        COMPILE_DIR => ($dir || "/tmp"),
        UNICODE     => 1,
        ENCODING    => 'utf-8',
        CACHE_SIZE  => 128,
        RELATIVE    => 1,
        ABSOLUTE    => 1,
    );

    $self->tt(Template->new( \%config ))
      or Carp::croak "Could not initialize Template object: $Template::ERROR";

    return $self;
}

sub _render {
    my ($self, $c, $tx, $path) = @_;

    #use Data::Dump qw(dump);
    #warn dump(\@args);

    my $output;
    unless ( $self->tt->process( $path, 
                                 { c  => $c,
                                   tx => $tx,
                                 },
                                 \$output,
                                 { binmode => ":utf8" }
                               )
           ) {
        Carp::carp $self->tt->error . "\n";
        return $self->tt->error;  
    }
    else {
        return $output;
    }
}

=head1 NAME

MojoX::Renderer::TT - Template Toolkit renderer for Mojo

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Perhaps a little code snippet.

    use MojoX::Renderer::TT;

    sub startup {
       ...
       $renderer->add_handler( tt => MojoX::Renderer::TT->new( mojo => $self ) );
    }


=head1 METHODS

=head2 new


=head1 AUTHOR

Ask Bjørn Hansen, C<< <ask at develooper.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-mojox-renderer-tt at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MojoX-Renderer-TT>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MojoX::Renderer::TT


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MojoX-Renderer-TT>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MojoX-Renderer-TT>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MojoX-Renderer-TT>

=item * Search CPAN

L<http://search.cpan.org/dist/MojoX-Renderer-TT/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Ask Bjørn Hansen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of MojoX::Renderer::TT
