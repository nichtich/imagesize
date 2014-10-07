use strict;
use Test::More;
use App::imagesize;

my $app = App::imagesize->new_from_args();
isa_ok $app, 'App::imagesize';

done_testing;
