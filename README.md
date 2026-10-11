# Барна карта коктейлів

Невеликий консольний застосунок на Dart — барна карта коктейлів. Отримує дані з публічного API TheCocktailDB, зберігає їх у `data.json` і відновлює під час наступного запуску.

## Запуск

```bash
dart pub get
dart run bin/main.dart
```

Запускається з кореня проєкту: `data.json` читається й записується в поточній папці.

## Меню

| Пункт | Що робить |
|-------|-----------|
| 1 | показати список коктейлів |
| 2 | додати коктейль |
| 3 | видалити коктейль за номером |
| 4 | завантажити коктейлі з API за назвою |
| 5 | пошук за частиною назви |
| 6 | сортування за назвою або категорією |
| 0 | вихід |

Усі зміни одразу записуються в `data.json`. Якщо файлу немає або він пошкоджений, застосунок стартує з порожнім списком. Відсутність інтернету та помилки сервера не завершують програму аварійно.

## API

```
GET https://www.thecocktaildb.com/api/json/v1/1/search.php?s=mojito
```

Реєстрація не потрібна. Якщо нічого не знайдено, API повертає `drinks: null`, а не порожній масив — сервіс це враховує.

## Структура

```
lab_dart/
├── bin/
│   └── main.dart                       консольне меню
├── lib/
│   ├── models/
│   │   ├── alcohol_type.dart           enum AlcoholType
│   │   ├── category.dart               модель Category
│   │   ├── cocktail.dart               модель Cocktail + розбір JSON
│   │   └── storable.dart               абстрактний клас Storable
│   ├── repositories/
│   │   └── cocktail_repository.dart    читання та запис data.json
│   ├── services/
│   │   ├── api_exception.dart          виняток ApiException
│   │   └── cocktail_api_service.dart   запити до TheCocktailDB
│   └── utils/
│       └── cocktail_utils.dart         пошук і сортування
└── test/
    └── cocktail_test.dart              модульні тести
```

Логіка розділена так, щоб мережа була ізольована в `cocktail_api_service.dart`, а файл — у `cocktail_repository.dart`. Пошук і сортування — чисті функції над моделями, тому тести не потребують інтернету.

## Що використано з мови

- `dart:io`, `dart:convert` — файли, `stdin` / `stdout`, `jsonEncode` / `jsonDecode`
- `async` / `await`, `Future` — запити до API
- пакет `http` — `http.Client` передається в сервіс через конструктор
- абстрактні класи й інтерфейси — `Storable`, `implements`
- перелічення — `AlcoholType`, `SortField`
- `factory`-конструктори — `fromJson`, `fromApi`
- null safety — `String?`, `??`, `?.`
- `switch`-вирази в меню та сортуванні
- колекції — `map`, `where`, `sort`, `toList`
- власний виняток — `ApiException`

## Тести

```bash
dart test
```

Тести перевіряють серіалізацію, розбір відповіді API, пошук, сортування та реакцію на некоректні дані. `http.Client` у тестах замінено на `MockClient`.

## Перевірка стилю

```bash
dart format .
dart analyze
```

## Автор

Генелюк Назар, ІПЗ-42, Волинський фаховий коледж НУХТ. Репозиторій: <https://github.com/Worgzz333r/Dart_Lab1.git>
