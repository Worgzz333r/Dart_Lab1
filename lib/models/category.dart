import 'storable.dart';

class Category implements Storable {
  final String name;

  Category(this.name);

  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(json['name'] as String);

  @override
  Map<String, dynamic> toJson() => {'name': name};

  @override
  String toString() => name;
}