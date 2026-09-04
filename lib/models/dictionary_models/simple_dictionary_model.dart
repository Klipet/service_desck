import 'package:service_desk/models/dictionaries_items/dictionary_item_model.dart';

// -----------------------------------------------------------
// Общая модель для простых справочников вида {oid, name, active,
// dateCreated, dateModifire}: WorkSpace, TiketType, State, Mode,
// PhoneResault, Category.
// -----------------------------------------------------------
class SimpleDictionaryModel {
  final int oid;
  final String name;
  final bool active;
  final DateTime dateCreated;
  final DateTime dateModifire;

  const SimpleDictionaryModel({
    this.oid = 0,
    required this.name,
    this.active = true,
    required this.dateCreated,
    required this.dateModifire,
  });

  factory SimpleDictionaryModel.fromJson(Map<String, dynamic> json) {
    return SimpleDictionaryModel(
      oid: json['oid'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      active: json['active'] as bool? ?? true,
      dateCreated:
          DateTime.tryParse(json['dateCreated'] as String? ?? '') ??
              DateTime.now(),
      dateModifire:
          DateTime.tryParse(json['dateModifire'] as String? ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'oid': oid,
    'name': name,
    'active': active,
    'dateCreated': dateCreated.toIso8601String(),
    'dateModifire': dateModifire.toIso8601String(),
  };
}

/// Для использования в CustomDictionaryDropdown, который работает
/// с DictionaryItem, а не с конкретными моделями сущностей.
extension SimpleDictionaryModelToItem on SimpleDictionaryModel {
  DictionaryItem toDictionaryItem() => DictionaryItem(
    oid: oid,
    name: name,
    active: active,
    dateCreated: dateCreated,
    dateModifire: dateModifire,
  );
}
