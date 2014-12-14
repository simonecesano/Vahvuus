package Vahvuus::Controller::Error;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Oxiana::Controller::Error - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{template} = 'error/index.tt2';
}

sub error :Path('/error') {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Oxiana::Controller::Error in Error foo.');
}

sub unimplemented :Path('/unimplemented') {
    my ( $self, $c ) = @_;
    $c->stash->{msg} = 'this feature is not implemented yet';
    $c->stash->{pic} = 'noun_5853_cc.svg';
    $c->stash->{template} = 'error/index.tt2';
}

=encoding utf8

=head1 AUTHOR

Cesano, Simone

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
