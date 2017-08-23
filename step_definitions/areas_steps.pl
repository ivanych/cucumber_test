#!perl
 
use strict;
use warnings;
use utf8;

use Test::More;
use Test::BDD::Cucumber::StepFile;
use DDP;

use lib '../lib', 'lib';
use Step;

When qr/загрузить регионы/, sub {
   S->{response} = Step::get_areas;
};

Then qr/в ответе есть город "(.+?)" с идентификатором "(.+?)" в стране с идентификатором "(.+?)"/, sub {
    my ($city_name, $city_id, $country_id) = ($1, $2, $3);

    my $path = '$[?($_->{id} == ' . $country_id . ')].areas[?($_->{id} == ' . $city_id . ')].name';

    my @values = Step::find_values(S->{'response'}->{content}, $path);

    is($values[0], $city_name, 'Find city');
};

Then qr/в ответе есть данные города "(\S+)" в стране "(\S+)"/, sub {
    my ($city_name, $country_name) = ($1, $2);

    my @values = Step::find_cities(S->{'response'}->{content}, $country_name, $city_name);
};

Given qr/получены данные страны "(\S+)"/, sub {
    my ($country_name) = ($1);

    # Получить страны
    my $country_aref = Step::load_countries($country_name);
    
    S->{$country_name} = $country_aref;
};

Given qr/получены данные города "(\S+)" в стране "(\S+)"/, sub {
    my ($city_name, $country_name) = ($1, $2);

    # Получить города
    my $city_aref = Step::load_cities($country_name, $city_name);
    
    S->{$city_name} = $city_aref;
};
