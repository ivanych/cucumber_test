#!perl
 
use strict;
use warnings;
use utf8;

use Test::More;
use Test::BDD::Cucumber::StepFile;
use DDP;

use lib 'step_definitions';
use Step;

Then qr/response decoded as JSON/, sub {
   Step::decode_as_json(S->{'response'}->{content});
};
