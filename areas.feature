Feature: Регионы    
    /areas
 
 Scenario: Выборочная проверка наличия заранее известных регионов
    When загрузить регионы
    Then response decoded as JSON
     And в ответе есть город "<area_name>" с идентификатором "<area_id>" в стране с идентификатором "<country_id>"
    Examples:
        | country_id | area_id | area_name |
        | 113  | 2 | Санкт-Петербург |
        | 113  | 1 | Москва |

 Scenario: получить данные города "Санкт-Петербург" в стране "Россия"
    When загрузить регионы
    Then response decoded as JSON
     And в ответе есть данные города "Санкт-Петербург" в стране "Россия"
