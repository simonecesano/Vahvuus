package Vahvuus::Controller::Perforce;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

__PACKAGE__->config(namespace => 'p');

use List::MoreUtils qw/indexes/;
use Vahvuus::Util qw/break/;
use Data::Dump qw/dump/;

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $path_re = quotemeta(join '/', '/', '');
    
    my $m = $c->model('Perforce');
    my @dirs = $m->views; $m->close;
    $c->stash->{dirs} = \@dirs;
    $c->stash->{regex} = qr/$path_re/i;
    $c->stash->{template} = 'perforce/list.tt2';
    $c->forward('View::HTML');
}

use Data::Page;

sub list :Path  {
    my ( $self, $c, @path ) = @_;

    my $page = Data::Page->new();
    $page->entries_per_page($c->req->params->{c} || 80);
    $page->current_page($c->req->params->{p} || 1);
    
    my @out;
    my $m = $c->model('Perforce');
    my $path_re = quotemeta(join '/', '/', @path, '');
    my $path = join '/', '/', @path, '*';

    my @dirs = $m->dirs(@path)->stdout; $m->close;
    my @files = map { s/#.+//; $_ } $m->run('files', '-e', $path)->stdout; $m->close;
    $page->total_entries(scalar @files);
    my @files_page = $page->splice(\@files);

    @files = $m->run('fstat', '-Ol', '-T', 'depotFile,fileSize,headTime,headModTime', @files_page)->stdout; $m->close;
    @files = map { { map { @$_ } @$_ } }                    # transform into hashrefs
    	break { scalar @$_ == 0 }                           # break apart at spaces
    	map { s/^\.\.\. //; [ split ' ', $_, 2 ] } @files;  # clean up


    $c->stash->{page} = $page;
    $c->stash->{path} = \@path;
    $c->stash->{p4path} = join '/', '/', @path, '...';
    $c->stash->{folder} = $path[-1];
    $c->stash->{files} = \@files;
    $c->stash->{dirs} = \@dirs;
    $c->stash->{regex} = qr/$path_re/i;
    
    $c->stash->{template} = 'perforce/list.tt2';
    $c->forward('View::HTML');
}

__PACKAGE__->meta->make_immutable;

1;
