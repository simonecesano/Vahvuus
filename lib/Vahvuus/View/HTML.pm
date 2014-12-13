package Vahvuus::View::HTML;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config({
    INCLUDE_PATH => [
        Vahvuus->path_to( 'root', 'src' ),
        Vahvuus->path_to( 'root', 'lib' )
    ],
    TEMPLATE_EXTENSION => '.tt2',
    PRE_PROCESS  => 'config/main.tt2',
    WRAPPER      => 'site/wrapper.tt2',
    ENCODING     => 'utf-8',
    ERROR        => 'error.tt2',
    TIMER        => 0,
    render_die   => 1,
});

=head1 NAME

Vahvuus::View::HTML - Catalyst TTSite View

=head1 SYNOPSIS

See L<Vahvuus>

=head1 DESCRIPTION

Catalyst TTSite View.

=head1 AUTHOR

Cesano, Simone

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

