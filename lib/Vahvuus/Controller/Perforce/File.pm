package Vahvuus::Controller::Perforce::File;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

__PACKAGE__->config(namespace => 'f');

use Vahvuus::Util qw/break/;
use Path::Tiny;

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Vahvuus::Controller::Perforce::File in Perforce::File.');
}

sub view :Path :Args {
    my ( $self, $c, @path ) = @_;
    my $temp = Path::Tiny->tempfile;
    my $path = join '/', '/', @path;
    my $m = $c->model('Perforce');
    my $ifh = $m->run('print', '-q', $path)->cmd->stdout;
    my $ofh = $temp->openw(":raw");
    while (<$ifh>) { print $ofh $_ };
    $c->log->info($temp);
    $c->log->info($m->stderr);
    my $mime = qx/file "$temp"/;
    $temp->remove;
    $c->response->body(sprintf 'View file %s type %s', (join '/', '/', @path), $mime);
}

sub upload :Path('upload') {
    my ( $self, $c ) = @_;
    my $path = $c->req->params->{path};
    $c->response->body(sprintf 'View file %s', ($path));
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
