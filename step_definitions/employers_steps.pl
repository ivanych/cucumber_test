#!perl
 
use strict;
use warnings;
use utf8;

use Test::More;
use Test::BDD::Cucumber::StepFile;
use DDP;

use lib '../lib', 'lib';
use Step;

Given qr/получены данные работодателя "(.+?)" в стране "(.+?)"/, sub {
    my ($employer_name, $country_name) = ($1, $2);

    # Получить работодателей
    my $employer_aref = Step::load_employers($employer_name, $country_name);

    S->{$employer_name} = $employer_aref;
};

When qr/загрузить данные работодателя "(.+?)" в стране "(.+?)"/, sub {
    my ($employer_name, $country_name) = ($1, $2);

    # Загрузить работодателей
    S->{response} = Step::get_employers({ text => $employer_name, area => S->{$country_name}->[0]->{id} });
};

Then qr/в ответе есть данные работодателя "(.+?)"/, sub {
    my ($employer_name) = ($1);

    # Найти работодателей
    my $employer_aref = Step::find_employers(S->{response}->{content}, $employer_name);
};
