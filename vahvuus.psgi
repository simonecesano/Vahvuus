use strict;
use warnings;

use Vahvuus;

my $app = Vahvuus->apply_default_middlewares(Vahvuus->psgi_app);
$app;

