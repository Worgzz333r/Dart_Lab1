import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/cocktail.dart';
import 'api_exception.dart';

class CocktailApiService {
  final http.Client _client;

  CocktailApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Cocktail>> searchByName(String name) async {
    final uri = Uri.https(
      'www.thecocktaildb.com',
      '/api/json/v1/1/search.php',
      {'s': name},
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw ApiException('Помилка сервера: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final drinks = data['drinks'] as List?; // null, якщо нічого не знайдено
    if (drinks == null) return [];
    return drinks
        .map((e) => Cocktail.fromApi(e as Map<String, dynamic>))
        .toList();
  }
}