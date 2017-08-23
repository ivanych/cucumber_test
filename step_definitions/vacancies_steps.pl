#!perl
 
use strict;
use warnings;
use utf8;

use Test::More;
use Test::BDD::Cucumber::StepFile;
use DDP;

use lib '../lib', 'lib';
use Step;

When qr/загрузить вакансию "(.+?)" в городе "(.+?)" у работодателя "(.+?)"/, sub {
    my ($vacancy_name, $city_name, $employer_name) = ($1, $2, $3);

    # Загрузить вакансии
    S->{response} = Step::get_vacancies({ text => $vacancy_name, area => S->{$city_name}->[0]->{id}, employer_id => S->{$employer_name}->[0]->{id} });
};

Then qr/в ответе есть данные вакансии "(.+?)"/, sub {
    my ($vacancy_name) = ($1);

    # Найти вакансии
    my $vacancy_aref = Step::find_vacancies(S->{response}->{content}, $vacancy_name);
};
