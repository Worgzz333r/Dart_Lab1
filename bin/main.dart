import 'dart:io';

import 'package:lab_dart/models/alcohol_type.dart';
import 'package:lab_dart/models/category.dart';
import 'package:lab_dart/models/cocktail.dart';
import 'package:lab_dart/repositories/cocktail_repository.dart';
import 'package:lab_dart/services/api_exception.dart';
import 'package:lab_dart/services/cocktail_api_service.dart';
import 'package:lab_dart/utils/cocktail_utils.dart';

Future<void> main() async {
  final repository = CocktailRepository();
  final service = CocktailApiService();
  final items = await repository.load();

  while (true) {
    printMenu();
    final choice = readLine('Оберіть пункт: ');
    switch (choice) {
      case '1':
        showList(items);
      case '2':
        await addCocktail(items, repository);
      case '3':
        await deleteCocktail(items, repository);
      case '4':
        await loadFromApi(items, repository, service);
      case '5':
        searchCocktails(items);
      case '6':
        await sortAndShow(items, repository);
      case '0':
        print('До побачення!');
        return;
      default:
        print('Невідомий пункт меню, спробуйте ще раз.');
    }
  }
}

void printMenu() {
  print('''

=== Барна карта коктейлів ===
1. Показати список
2. Додати коктейль
3. Видалити коктейль
4. Завантажити з API
5. Пошук
6. Сортування
0. Вихід''');
}

String readLine(String prompt) {
  stdout.write(prompt);
  return (stdin.readLineSync() ?? '').trim();
}

void showList(List<Cocktail> list) {
  if (list.isEmpty) {
    print('Список порожній.');
    return;
  }
  for (var i = 0; i < list.length; i++) {
    print('${i + 1}. ${list[i]}');
  }
}

Future<void> addCocktail(
  List<Cocktail> items,
  CocktailRepository repository,
) async {
  final name = readLine('Назва: ');
  if (name.isEmpty) {
    print('Назва не може бути порожньою.');
    return;
  }
  final categoryName = readLine('Категорія (Enter — «Невідомо»): ');
  final typeChoice = readLine(
    'Тип (1 — алкогольний, 2 — безалкогольний, 3 — за бажанням): ',
  );
  final type = switch (typeChoice) {
    '1' => AlcoholType.alcoholic,
    '2' => AlcoholType.nonAlcoholic,
    _ => AlcoholType.optional,
  };
  final ingredients = readLine(
    'Інгредієнти (через кому): ',
  ).split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  items.add(
    Cocktail(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: Category(categoryName.isEmpty ? 'Невідомо' : categoryName),
      type: type,
      ingredients: ingredients,
    ),
  );
  await repository.save(items);
  print('Додано.');
}

Future<void> deleteCocktail(
  List<Cocktail> items,
  CocktailRepository repository,
) async {
  if (items.isEmpty) {
    print('Список порожній, нічого видаляти.');
    return;
  }
  showList(items);
  final number = int.tryParse(readLine('Номер для видалення: '));
  if (number == null || number < 1 || number > items.length) {
    print('Некоректний номер.');
    return;
  }
  final removed = items.removeAt(number - 1);
  await repository.save(items);
  print('Видалено: ${removed.name}');
}

Future<void> loadFromApi(
  List<Cocktail> items,
  CocktailRepository repository,
  CocktailApiService service,
) async {
  final query = readLine('Що шукати в API (наприклад, mojito): ');
  if (query.isEmpty) {
    print('Запит не може бути порожнім.');
    return;
  }
  try {
    final found = await service.searchByName(query);
    final fresh = found.where((f) => !items.any((i) => i.id == f.id)).toList();
    items.addAll(fresh);
    await repository.save(items);
    print('Знайдено: ${found.length}, додано нових: ${fresh.length}.');
  } on SocketException {
    print('Немає з\'єднання з інтернетом. Працюємо з локальними даними.');
  } on ApiException catch (e) {
    print('Сервер недоступний: $e');
  } on FormatException {
    print('Сервер повернув некоректні дані.');
  } catch (e) {
    print('Не вдалося отримати дані: $e');
  }
}

void searchCocktails(List<Cocktail> items) {
  final query = readLine('Пошук за назвою: ');
  final results = searchLocal(items, query);
  if (results.isEmpty) {
    print('Нічого не знайдено.');
    return;
  }
  showList(results);
}

Future<void> sortAndShow(
  List<Cocktail> items,
  CocktailRepository repository,
) async {
  final choice = readLine('Сортувати за: 1 — назвою, 2 — категорією: ');
  final field = switch (choice) {
    '1' => SortField.name,
    '2' => SortField.category,
    _ => null,
  };
  if (field == null) {
    print('Некоректний вибір.');
    return;
  }
  final sorted = sortCocktails(items, field);
  items
    ..clear()
    ..addAll(sorted);
  await repository.save(items);
  showList(items);
}
