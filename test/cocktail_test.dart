import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab_dart/models/alcohol_type.dart';
import 'package:lab_dart/models/category.dart';
import 'package:lab_dart/models/cocktail.dart';
import 'package:lab_dart/services/api_exception.dart';
import 'package:lab_dart/services/cocktail_api_service.dart';
import 'package:lab_dart/utils/cocktail_utils.dart';
import 'package:test/test.dart';

Cocktail make(String id, String name, String category) => Cocktail(
  id: id,
  name: name,
  category: Category(category),
  type: AlcoholType.alcoholic,
  ingredients: ['Rum', 'Mint'],
);

void main() {
  group('Cocktail JSON', () {
    final mojito = make('1', 'Mojito', 'Cocktail');

    test('toJson повертає правильну мапу', () {
      expect(mojito.toJson(), {
        'id': '1',
        'name': 'Mojito',
        'category': {'name': 'Cocktail'},
        'type': 'alcoholic',
        'ingredients': ['Rum', 'Mint'],
      });
    });

    test('fromJson відновлює обєкт (туди й назад)', () {
      final restored = Cocktail.fromJson(mojito.toJson());
      expect(restored.id, equals('1'));
      expect(restored.name, equals('Mojito'));
      expect(restored.category.name, equals('Cocktail'));
      expect(restored.type, equals(AlcoholType.alcoholic));
      expect(restored.ingredients, equals(['Rum', 'Mint']));
    });

    test('fromApi збирає інгредієнти й пропускає null та порожні', () {
      final drink = Cocktail.fromApi({
        'idDrink': '11000',
        'strDrink': 'Mojito',
        'strCategory': 'Cocktail',
        'strAlcoholic': 'Alcoholic',
        'strIngredient1': 'Light rum',
        'strIngredient2': 'Lime',
        'strIngredient3': null,
        'strIngredient4': '',
      });
      expect(drink.ingredients, equals(['Light rum', 'Lime']));
      expect(drink.type, equals(AlcoholType.alcoholic));
    });

    test('некоректний type у JSON дає ArgumentError', () {
      final bad = mojito.toJson()..['type'] = 'unknown';
      expect(() => Cocktail.fromJson(bad), throwsA(isA<ArgumentError>()));
    });
  });

  group('Пошук і сортування', () {
    final items = [
      make('1', 'Mojito', 'Cocktail'),
      make('2', 'Bloody Mary', 'Ordinary Drink'),
      make('3', 'Mango Mojito', 'Cocktail'),
    ];

    test('пошук повертає лише збіги за назвою', () {
      final result = searchLocal(items, 'mojito');
      expect(result, hasLength(2));
      expect(result.every((c) => c.name.contains('Mojito')), isTrue);
    });

    test('сортування за назвою впорядковує список', () {
      final sorted = sortCocktails(items, SortField.name);
      expect(
        sorted.map((c) => c.name).toList(),
        equals(['Bloody Mary', 'Mango Mojito', 'Mojito']),
      );
    });
  });

  group('CocktailApiService', () {
    test('розбирає відповідь із MockClient', () async {
      final client = MockClient(
        (request) async => http.Response(
          '{"drinks": [{"idDrink": "1", "strDrink": "Mojito", '
          '"strCategory": "Cocktail", "strAlcoholic": "Alcoholic", '
          '"strIngredient1": "Rum"}]}',
          200,
        ),
      );
      final result = await CocktailApiService(client: client).searchByName('m');
      expect(result, hasLength(1));
      expect(result.first.name, equals('Mojito'));
    });

    test('drinks: null дає порожній список', () async {
      final client = MockClient(
        (request) async => http.Response('{"drinks": null}', 200),
      );
      final result = await CocktailApiService(client: client).searchByName('x');
      expect(result, isEmpty);
    });

    test('статус 500 кидає ApiException', () async {
      final client = MockClient((request) async => http.Response('', 500));
      expect(
        CocktailApiService(client: client).searchByName('x'),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
