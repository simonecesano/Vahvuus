package Vahvuus::Util;

require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(break);

sub break(&@) {
    my $sub = shift;
    my @out = (); my $cum = [];
    for (@_) {
	if ($sub->()) { push @out, $cum; $cum = [] } else { push @$cum, $_ }
    }
    return @out;
}

1;
