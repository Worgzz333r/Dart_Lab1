import 'alcohol_type.dart';
import 'category.dart';
import 'storable.dart';

class Cocktail implements Storable {
  final String id;
  final String name;
  final Category category;
  final AlcoholType type;
  final List<String> ingredients;

  Cocktail({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.ingredients,
  });

  // З нашого data.json
  factory Cocktail.fromJson(Map<String, dynamic> json) => Cocktail(
    id: json['id'] as String,
    name: json['name'] as String,
    category: Category.fromJson(json['category'] as Map<String, dynamic>),
    type: AlcoholType.values.byName(json['type'] as String),
    ingredients: (json['ingredients'] as List).map((e) => e as String).toList(),
  );

  // З відповіді TheCocktailDB
  factory Cocktail.fromApi(Map<String, dynamic> json) {
    final ingredients = <String>[];
    for (var i = 1; i <= 15; i++) {
      final value = (json['strIngredient$i'] as String?)?.trim();
      if (value != null && value.isNotEmpty) ingredients.add(value);
    }
    return Cocktail(
      id: json['idDrink'] as String,
      name: json['strDrink'] as String? ?? 'Без назви',
      category: Category(json['strCategory'] as String? ?? 'Невідомо'),
      type: AlcoholType.fromApi(json['strAlcoholic'] as String?),
      ingredients: ingredients,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category.toJson(),
    'type': type.name,
    'ingredients': ingredients,
  };

  @override
  String toString() =>
      '#$id $name [$category, ${type.name}] — ${ingredients.join(', ')}';
}
