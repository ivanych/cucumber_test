# Somehow I don't see this replacing the other tests this module has...
Feature: Simple tests of api.hh.ru
 апи хэхэру
 
 Background:
   Given load module HTTP::Tiny
   And create object HTTP::Tiny

 Scenario: Загрузка справочника регионов
   When request GET /areas
   Then response is valid JSON
   And area id=2 in country id=113 has name=Санкт-Петербург
