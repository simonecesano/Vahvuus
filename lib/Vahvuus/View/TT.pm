package Vahvuus::View::TT;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt2',
    render_die => 1,
);

=head1 NAME

Vahvuus::View::TT - TT View for Vahvuus

=head1 DESCRIPTION

TT View for Vahvuus.

=head1 SEE ALSO

L<Vahvuus>

=head1 AUTHOR

Cesano, Simone

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
