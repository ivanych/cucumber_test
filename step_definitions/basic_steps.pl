#!perl
 
use strict;
use warnings;

use Encode;
use Test::More;
use Test::BDD::Cucumber::StepFile;
use JSON;
use Try::Tiny;
use JSON::Path;
use DDP;

$JSON::Path::Safe = 0;

my $host = 'http://api.hh.ru';
 
Given qr/load module (.+)/, sub {
     use_ok( $1 );
};

Given qr/create object (.+)/, sub {
     my $http = $1->new();
     ok( $http, "Object created" );
     S->{'http'} = $http;
};

When qr/request (\S+) (\S+)/, sub {
   my $url = $host . $2;
   diag($url);
   
   my $response = S->{'http'}->request($1, $url);
   
   ok($response, 'Request completed');
   ok($response->{success}, 'Request success');
   
   S->{'response'} = $response;
   
};
 
Then qr/response is valid JSON/, sub {
   my $result = try {
       decode_json(S->{'response'}->{content});
   };

   ok($result, 'Content decoded as json');
};

Then qr/area id=(\S+) in country id=(\S+) has name=(\S+)/, sub {
    my ($country_id, $area_id, $area_name) = ($2, $1, $3);

    my $jpath = JSON::Path->new('$[?($_->{id} == ' . $country_id . ')].areas[?($_->{id} == ' . $area_id . ')].name');
    my ($val) = $jpath->values(S->{'response'}->{content});

    is($val, $area_name, 'Match name');
    
};
