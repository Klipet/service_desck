class WorkSpaceItem {
  final int oid;
  final String name;
  final bool active;
  final DateTime? dateCreated;
  final List<UserItem>? users;

  WorkSpaceItem({
    required this.oid,
    required this.name,
    required this.active,
    this.dateCreated,
    required this.users,
  });

  factory WorkSpaceItem.fromJson(Map<String, dynamic> json) {
    return WorkSpaceItem(
      oid: json['oid'] as int,
      name: json['name'] as String? ?? '',
      active: json['active'] as bool? ?? false,
      dateCreated: _parseDate(json['dateCreated']),
      users: (json['user'] as List<dynamic>? ?? [])
          .map((e) => UserItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class UserItem {
  final int oid;
  final String name;
  final bool active;
  final DateTime? dateCreated;
  final DateTime? dateModifire;

  UserItem({
    required this.oid,
    required this.name,
    required this.active,
    this.dateCreated,
    this.dateModifire,
  });

  factory UserItem.fromJson(Map<String, dynamic> json) {
    return UserItem(
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