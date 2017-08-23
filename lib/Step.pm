package Step;
 
use strict;
use warnings;
use utf8;

use Carp;
use HTTP::Tiny;
use JSON;
use JSON::Path;
use Test::More;
use Try::Tiny;
use DDP;

$JSON::Path::Safe = 0;

my $host = 'https://api.hh.ru';

# Декодировать ответ как JSON
sub decode_as_json {
   my ($json) = @_;
   
   #diag('JSON = ' . np $json);
   
   my $result = try {
      decode_json($json);
   }
   catch {
       diag($_);
       
       return;
   };

   ok($result, 'Content decoded as json');

   return $result;
}

# Загрузить ресурс
sub get {
   my ($url, $args) = @_;

   my $http = HTTP::Tiny->new(agent=>'test');
   
   if ($args) {
       my $params = $http->www_form_urlencode( $args );
   
       $url .= "?$params";
   }

   diag('URL = ' . np $url);

   my $response = $http->get($url);

   ok($response, 'Request completed');
   ok($response->{success}, 'Request success');

   return $response;
}

# Загрузить регионы
sub get_areas {
   my $url = $host . '/areas';

   return Step::get($url);
}

# Загрузить работодателей
sub get_employers {
    my ($args) = @_;
    
    my $url = $host . '/employers';

    return Step::get($url, $args);
}

# Загрузить вакансии
sub get_vacancies {
    my ($args) = @_;
    
    my $url = $host . '/vacancies';

    return Step::get($url, $args);
}

# Найти данные
sub find_values {
    my ($json, $path) = @_;

    diag('$path = ' . np $path);
    
    #diag($json);

    my @values = try {
        local $Carp::CarpLevel = 1;
        JSON::Path->new($path)->values($json);
    }
    catch {
        diag($_);

        return;
    }
    finally {
        ok(!@_, "Get json values");
    };

    return @values;
}

# Найти страны
sub find_countries {
    my ($json, $country_name) = @_;
    
    my $path = '$[?($_->{name} eq ' . $country_name . ')]';

    my @values = find_values($json, $path);

    ok(@values, 'Find countries');

    return \@values;
}

# Найти города
sub find_cities {
    my ($json, $country_name, $city_name) = @_;
    
    my $path = '$[?($_->{name} eq ' . $country_name . ')].areas[?($_->{name} =~ /' . $city_name . '/)]';

    my @values = find_values($json, $path);

    ok(@values, 'Find cities');
    
    return \@values;
}

# Найти работодателей
sub find_employers {
    my ($json, $employer_name) = @_;

    my $path = '$items[?($_->{name} eq q{' . $employer_name . '})]';

    my @values = find_values($json, $path);

    ok(@values, 'Find employers');

    return \@values;
}


# Найти вакансии
sub find_vacancies {
    my ($json, $vacancy_name) = @_;
    
    # Тут подвох - в названии вакансии QA Automation есть невидимый юникодный символ, 
    # из-за него затруднительно проверить точное совпадение.
    # Поэтому проверяем регуляркой частичное совпадение
    my $path = '$items[?($_->{name} =~ /' . $vacancy_name . '/)]';

    my @values = find_values($json, $path);

    ok(@values, 'Find vacancies');

    return \@values;
}

# Получить даные стран
sub load_countries {
    my ($country_name) = @_;

    # Загрузить регионы
    my $response = Step::get_areas();

    # Найти страны
    return Step::find_countries($response->{content}, $country_name);
}

# Получить данные городов
sub load_cities {
    my ($country_name, $city_name) = @_;

    # Загрузить регионы
    my $response = Step::get_areas();

    # Найти города
    return Step::find_cities($response->{content}, $country_name, $city_name);
}

# Получить данные работодателей
sub load_employers {
    my ($employer_name, $country_name) = @_;

    # Загрузить страны
    my $country_aref = Step::load_countries($country_name);

    # Загрузить работодателей
    my $response = Step::get_employers({ text => $employer_name, area => $country_aref->[0]->{id} });

    # Найти работодателей
    return Step::find_employers($response->{content}, $employer_name);
}

1;