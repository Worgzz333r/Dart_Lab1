import 'dart:convert';
import 'dart:io';

import '../models/cocktail.dart';

class CocktailRepository {
  final String path;

  CocktailRepository({this.path = 'data.json'});

  Future<List<Cocktail>> load() async {
    final file = File(path);
    if (!await file.exists()) return [];

    try {
      final raw = await file.readAsString();
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Cocktail.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      print('Файл $path пошкоджено, починаємо з порожнього списку.');
      return [];
    } on TypeError {
      print(
        'Файл $path має неправильну структуру, починаємо з порожнього списку.',
      );
      return [];
    } on ArgumentError {
      print(
        'Файл $path містить некоректні значення, починаємо з порожнього списку.',
      );
      return [];
    }
  }

  Future<void> save(List<Cocktail> items) async {
    const encoder = JsonEncoder.withIndent('  ');
    await File(path).writeAsString(encoder.convert(items));
  }
}
