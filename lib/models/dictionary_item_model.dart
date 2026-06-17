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

  static DateTime? _parseDate(dynamic value) {
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

  @override
  String toString() => 'DictionaryItem(oid: $oid, name: $name, active: $active)';
}

class DictionariesResponse {
  final List<DictionaryItem> tiketType;
  final List<DictionaryItem> tiketState;
  final List<DictionaryItem> tiketPreority;
  final List<DictionaryItem> tiketMode;
  final List<DictionaryItem> tiketCategory;
  final List<DictionaryItem> tiketWorkSpace;

  DictionariesResponse({
    required this.tiketType,
    required this.tiketState,
    required this.tiketPreority,
    required this.tiketMode,
    required this.tiketCategory,
    required this.tiketWorkSpace,
  });

  factory DictionariesResponse.fromJson(Map<String, dynamic> json) {
    List<DictionaryItem> parseList(String key) {
      final raw = json[key] as List<dynamic>? ?? [];
      return raw
          .map((e) => DictionaryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return DictionariesResponse(
      tiketType: parseList('tiketType'),
      tiketState: parseList('tiketState'),
      tiketPreority: parseList('tiketPreority'),
      tiketMode: parseList('tiketMode'),
      tiketCategory: parseList('tiketCategory'),
      tiketWorkSpace: parseList('tiketWorkSpace'),
    );
  }
}