
class CategoryItem {
  final int oid;
  final String name;
  final bool active;
  final DateTime? dateCreated;
  final List<SubCategory> subCategory;

  CategoryItem({
    required this.oid,
    required this.name,
    required this.active,
    this.dateCreated,
    required this.subCategory,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      oid: json['oid'] as int,
      name: json['name'] as String? ?? '',
      active: json['active'] as bool? ?? false,
      dateCreated: _parseDate(json['dateCreated']),
      subCategory: (json['subCategories'] as List<dynamic>? ?? [])
          .map((e) => SubCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SubCategory {
  final int oid;
  final String name;
  final bool active;
  final DateTime? dateCreated;
  final DateTime? dateModifire;

  SubCategory({
    required this.oid,
    required this.name,
    required this.active,
    this.dateCreated,
    this.dateModifire,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      oid: json['oid'] as int,
      name: json['name'] as String? ?? '',
      active: json['active'] as bool? ?? false,
      dateCreated: _parseDate(json['dateCreated']),
      dateModifire: _parseDate(json['dateModifire']),
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  final str = value as String;
  // "0001-01-01T00:00:00" — некорректная для DateTime.parse дата по сути валидна,
  // но если бэк когда-нибудь пришлёт что-то совсем кривое — подстрахуемся try/catch
  try {
    return DateTime.parse(str);
  } catch (_) {
    return null;
  }
}