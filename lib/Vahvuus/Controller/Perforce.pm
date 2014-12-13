package Vahvuus::Controller::Perforce;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

__PACKAGE__->config(namespace => 'p');

use List::MoreUtils qw/indexes/;
use Data::Dump qw/dump/;


sub break(&@) {
    my $sub = shift;
    my @out = (); my $cum = [];
    for (@_) {
	if ($sub->()) { push @out, $cum; $cum = [] } else { push @$cum, $_ }
    }
    return @out;
}


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

sub list :Path  {
    my ( $self, $c, @path ) = @_;

    my @out;
    my $m = $c->model('Perforce');
    my $path_re = quotemeta(join '/', '/', @path, '');
    my $path = join '/', '/', @path, '*';
    my @dirs = $m->dirs(@path)->stdout; $m->close;
    $c->log->info("Dirs:\n", @dirs);
    
    my @files = map { s/#.+//; $_ } $m->run('files', '-e', $path)->stdout; $m->close;
    $c->log->info("path: ", $path);
    $c->log->info("Files:\n", @files);
    
    @files = $m->run('fstat', '-Ol', '-T', 'depotFile,fileSize,headTime,headModTime', @files)->stdout; $m->close;

    $c->log->info("Files:\n", @files);
    
    @files = map { { map { @$_ } @$_ } }                    # transform into hashrefs
    	break { scalar @$_ == 0 }                           # break apart at spaces
    	map { s/^\.\.\. //; [ split ' ', $_, 2 ] } @files;  # clean up


    $c->stash->{path} = \@path;
    $c->stash->{folder} = $path[-1];
    $c->stash->{files} = \@files;
    $c->stash->{dirs} = \@dirs;
    $c->stash->{regex} = qr/$path_re/i;
    
    $c->stash->{template} = 'perforce/list.tt2';
    $c->forward('View::HTML');
}

__PACKAGE__->meta->make_immutable;

1;
