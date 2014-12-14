package Vahvuus::Controller::Perforce::Work;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

__PACKAGE__->config(namespace => 'w');

use Vahvuus::Util qw/break/;
use Number::Bytes::Human qw(format_bytes);
use Data::Dump qw/dump/;
use List::Util qw/sum/;

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->response->body('Matched Vahvuus::Controller::Perforce::Work in Perforce::Work.');
}

sub create_folder :Path('folder') {
    my ( $self, $c ) = @_;
    my $path = $c->req->params->{path};
    $c->response->body(sprintf 'Create folder %s', ($path));
}

sub size_files :Path('size') {
    my ( $self, $c ) = @_;
    my $path = $c->req->params->{path};
    for ($path) { s/^\/+//; s/\.+$//; s/\/$// }
    my $r = $c->model('Perforce')->run('fstat', '-Ol', '-m', '500', '//' . $path . '/...');

    my @dump = $r->stdout;
    my @files = map { { map { @$_ } @$_ } } break { (scalar @$_) < 1 } map { s/^\.\.\. //; [ split ' ', $_, 2 ]; } @dump;
    
    $c->stash->{count} = scalar @files;
    $c->stash->{size} = format_bytes(sum map { $_->{fileSize} } @files);
    $c->forward('View::JSON');
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
