package Catalyst::Model::Command;

use strict;
use warnings;

use System::Command;
use Moose;

extends 'Catalyst::Model';

has 'cmd' 
    => (
	is  => 'rw',
	isa => 'System::Command',
	lazy    => 1,
	default => sub { System::Command->new(':') },
	handles => [qw( pid exit signal core is_terminated options cmdline )],
       );

has 'error' => ( is => 'rw' );

sub run {
    my $self = shift;
    my @cmd = @_;
    local $\ = "\n";
    print STDERR "\n" . ('-' x 80);
    print STDERR join ' ', @cmd;
    print STDERR "\n" . ('-' x 80);
    $self->cmd(System::Command->new(@cmd));
    return $self;
}

sub stderr {
    my $self = shift;
    my $stderr = $self->cmd->stderr;
    return map { chomp; $_ } <$stderr>;
}

sub stdout {
    my $self = shift;
    my $stdout = $self->cmd->stdout;
    return map { chomp; $_ } <$stdout>;
}


sub close {
    my $self = shift;
    $self->is_terminated;

    if ($self->exit) {
	my $stderr = $self->stderr;
	my $stdout = $self->stdout;
	my $full = join ' ', $self->cmdline;
	$self->error("$full failed:" . <$stderr> . <$stdout>);
    }
    $self->cmd->close;
    return $self;
}

1;


__DATA__

sub run_and_close {
    my ($self, @cmd) = grep { !(ref $_) } @_;
    my ($stdout, $stderr, $opts) = grep { ref $_ } @_;
    
    $self->run(@cmd);
    push @$$stdout, $self->stdout;
    push @$$stderr, $self->stderr;
    return $self;
}
