import '../models/cocktail.dart';

enum SortField { name, category }

List<Cocktail> searchLocal(List<Cocktail> items, String query) {
  final q = query.trim().toLowerCase();
  return items.where((c) => c.name.toLowerCase().contains(q)).toList();
}

List<Cocktail> sortCocktails(List<Cocktail> items, SortField field) {
  final copy = List<Cocktail>.of(items);
  copy.sort((a, b) => switch (field) {
        SortField.name => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        SortField.category => a.category.name
            .toLowerCase()
            .compareTo(b.category.name.toLowerCase()),
      });
  return copy;
}