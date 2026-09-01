import 'package:service_desk/models/dictionaries_items/catigory_item.dart';
import 'package:service_desk/models/dictionaries_items/phone_resault_item.dart';

import 'work_space_item.dart';

class DictionaryItem {
  final int oid;
  final String name;
  final bool active;
  final DateTime? dateCreated;
  final DateTime? dateModifire;



  DictionaryItem({
    required this.oid,
    required this.name,
    required this.active,
    this.dateCreated,
    this.dateModifire,
  });

  factory DictionaryItem.fromJson(Map<String, dynamic> json) {
    return DictionaryItem(
      oid: json['oid'] as int,
      name: json['name'] as String? ?? '',
      active: json['active'] as bool? ?? false,
      dateCreated: _parseDate(json['dateCreated']),
      dateModifire: _parseDate(json['dateModifire']),
   );
  }

  Map<String, dynamic> toJson() {
    return {
      'oid': oid,
      'name': name,
      'active': active,
      'dateCreated': dateCreated?.toIso8601String(),
      'dateModifire': dateModifire?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'DictionaryItem(oid: $oid, name: $name, active: $active)';
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

class DictionariesResponse {
  final List<DictionaryItem> tiketType;
  final List<DictionaryItem> tiketState;
  final List<DictionaryItem> tiketPreority;
  final List<DictionaryItem> tiketMode;
  final List<CategoryItem> tiketCategory;
  final List<WorkSpaceItem> tiketWorkSpace;
  final List<PhoneResaultItem> phoneResault;

  DictionariesResponse({
    required this.tiketType,
    required this.tiketState,
    required this.tiketPreority,
    required this.tiketMode,
    required this.tiketCategory,
    required this.tiketWorkSpace,
    required this.phoneResault,
  });

  factory DictionariesResponse.fromJson(Map<String, dynamic> json) {
    List<DictionaryItem> parseList(String key) {
      final raw = json[key] as List<dynamic>? ?? [];
      return raw
          .map((e) => DictionaryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    List<WorkSpaceItem> parseWorkSpaces(String key) {
      final raw = json[key] as List<dynamic>? ?? [];
      return raw
          .map((e) => WorkSpaceItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<PhoneResaultItem> parsePhoneResault(String key) {
      final raw = json[key] as List<dynamic>? ?? [];
      return raw
          .map((e) => PhoneResaultItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<CategoryItem> parseCategories(String key) {
      final raw = json[key] as List<dynamic>? ?? [];
      return raw
          .map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return DictionariesResponse(
      tiketType: parseList('tiketType'),
      tiketState: parseList('tiketState'),
      tiketPreority: parseList('tiketPreority'),
      tiketMode: parseList('tiketMode'),
      tiketCategory: parseCategories('tiketCategory'),
      tiketWorkSpace: parseWorkSpaces('tiketWorkSpace'),
      phoneResault: parsePhoneResault('phoneResault'),
    );
  }
}
