// -----------------------------------------------------------
// Phone (вложен в AuthorCreateModel, соответствует PhoneDtoAuthor)
// -----------------------------------------------------------
class AuthorPhoneModel {
  final int oid;
  final String? number;
  final DateTime dataCreated;

  const AuthorPhoneModel({
    this.oid = 0,
    this.number,
    required this.dataCreated,
  });

  factory AuthorPhoneModel.fromJson(Map<String, dynamic> json) {
    return AuthorPhoneModel(
      oid: json['oid'] as int? ?? 0,
      number: json['number'] as String?,
      dataCreated: DateTime.tryParse(json['dataCreated'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'oid': oid,
    'number': number,
    'dataCreated': dataCreated.toIso8601String(),
  };
}

// -----------------------------------------------------------
// Author (создание, соответствует AuthorDto из /Author/CreateAuthor)
// -----------------------------------------------------------
class AuthorCreateModel {
  final int oid;
  final String name;
  final bool active;
  final DateTime dateCreated;
  final DateTime dateModifire;
  final List<AuthorPhoneModel> phone;
  final String? email;
  final int platformId;

  const AuthorCreateModel({
    this.oid = 0,
    required this.name,
    this.active = true,
    required this.dateCreated,
    required this.dateModifire,
    this.phone = const [],
    this.email,
    required this.platformId,
  });

  factory AuthorCreateModel.fromJson(Map<String, dynamic> json) {
    return AuthorCreateModel(
      oid: json['oid'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      active: json['active'] as bool? ?? true,
      dateCreated:
          DateTime.tryParse(json['dateCreated'] as String? ?? '') ??
              DateTime.now(),
      dateModifire:
          DateTime.tryParse(json['dateModifire'] as String? ?? '') ??
              DateTime.now(),
      phone: (json['phone'] as List<dynamic>?)
              ?.map((e) => AuthorPhoneModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      email: json['email'] as String?,
      platformId: json['platformId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'oid': oid,
    'name': name,
    'active': active,
    'dateCreated': dateCreated.toIso8601String(),
    'dateModifire': dateModifire.toIso8601String(),
    'phone': phone.map((e) => e.toJson()).toList(),
    'email': email,
    'platformId': platformId,
  };
}
