package Vahvuus::Model::Perforce;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

extends 'Catalyst::Model::Command';

sub run {
    my $self = shift;
    my @cmd = @_;
    @cmd = ('p4', '-u', 'svc_desi_std', @cmd)
	unless $_[0] =~ /p4\s*/;
    return $self->SUPER::run(@cmd);
}

use Data::Dump qw/dump/;

local $\ = "\n";

sub dirs {
    my $self = shift;
    my @path = @_;

    return $self->run('dirs', (join '/', '/', @path, '*'));

}

sub files {
    my $self = shift;

    my ($filter, $re);
    for (ref $_[-1]) {
	/Regexp/ && do { 
	    $re = pop @_;
	};
	/SCALAR/ && do {
	    $filter = pop @_;
	    $filter = join '', '*', $$filter, '*';
	};
    };

    my @path = @_;
    my $q = $filter ? 
	(join '/', '/', @path, '...', $filter, '...')
	: (join '/', '/', @path, '...');

    $self = $self->run('files', '-e', $q);
    print STDERR "$q\n";
    return $self;
}

use List::MoreUtils qw/uniq firstidx/;

sub fstat {
    my $self = shift;
    my $root = shift;
    my $search = join '', map { /[a-z]/i ? (join '', '[', $_, uc, ']') : quotemeta($_)  } split '', shift;

    my $opt = shift;

    $opt->{depth} = 8;
    $opt->{uniq} = 1;

    $self = $self->run('fstat', '-Ol',  '-T', 'depotFile, fileSize, headTime, headModTime, digest', '-F', 'depotFile~=' . $search, $root);
    print STDERR ((join ' ', map { qq("$_") } $self->cmdline) . "\n");
    my @data = map { { map { s/\.\.\. //; split / /, $_, 2 } split /\n/, $_ } } split /\n\n/, join "\n", $self->stdout;

    if (my $d = $opt->{depth}) { for (@data) {
	$_->{depotFile} = join '/', @{ [ split '/', $_->{depotFile} ]}[0..(1 + $opt->{depth})]
    } }

    if ($opt->{uniq}) { 
	my $d;
	for (@data) {
	    $d->{$_->{depotFile}}->{depotFile} = $_->{depotFile};
	    $d->{$_->{depotFile}}->{count}++;

	    $d->{$_->{depotFile}}->{fileSize} += $_->{fileSize};
	    $d->{$_->{depotFile}}->{headTime} = $_->{headTime} if $d->{$_->{depotFile}}->{headTime} < $_->{headTime};
	    $d->{$_->{depotFile}}->{headModTime} = $_->{headModTime} if $d->{$_->{depotFile}}->{headModTime} < $_->{headModTime};
	}
	@data = map { $d->{$_} } keys %$d; 
    }
    

    return \@data;
}

sub root {
    my $self = shift;
    my $root = shift;
    my $dir = shift;

    for ($root) { s/^\/+//; s/\.\.\.$//; s/\*$//; s/\/$//; }
    $root = '//' . $root;
    
    if ($dir) { $root .= '/*' } else { $root .= '/...' }
    $root =~ s|///|//|;

    print STDERR "$root\n";

    return $root;
}

sub views {
    my $self = shift;
    my @views = $self->run('client', '-o')->stdout;
    my $i = firstidx { /^View:/ } @views;
    @views = map { s/^\s+//; s/\.\.\..+//; s/\/$//; $_ } @views[($i+1)..$#views];
}

1;


__DATA__

5466
