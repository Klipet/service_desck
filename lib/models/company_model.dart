import 'platform_model.dart';

// -----------------------------------------------------------
// Autor
// -----------------------------------------------------------
class AuthorModel {
  final List<Phone>? phone;
  final String? email;
  final String? platformName;
  final int platformId;
  final int oid;
  final String name;
  final bool active;
  final DateTime dateCreated;
  final DateTime dateModifire;

  const AuthorModel({
    required this.phone,
    required this.email,
    required this.platformName,
    required this.platformId,
    required this.oid,
    required this.name,
    required this.active,
    required this.dateCreated,
    required this.dateModifire,
  });

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      phone: (json['phone'] as List<dynamic>?)
        ?.map((e) => Phone.fromJson(e as Map<String, dynamic>))
        .toList() ??
        [],
      email: json['email'] as String?,
      platformName: json['platformName'] as String?,
      platformId: json['platformId'] as int,
      oid: json['oid'] as int,
      name: json['name'] as String,
      active: json['active'] as bool,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      dateModifire: DateTime.parse(json['dateModifire'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'email': email,
    'platformName': platformName,
    'platformId': platformId,
    'oid': oid,
    'name': name,
    'active': active,
    'dateCreated': dateCreated.toIso8601String(),
    'dateModifire': dateModifire.toIso8601String(),
  };
}

// -----------------------------------------------------------
// Phone
// -----------------------------------------------------------

class Phone {
  final int? oid;
  final String? number;
  final DateTime? dataCreated;

  Phone({this.oid, this.number, this.dataCreated});

  factory Phone.fromJson(Map<String, dynamic> json) {
    return Phone(
      oid: json['oid'] as int?,
      number: json['number'] as String?,
      dataCreated:
          json['dataCreated'] != null &&
              json['dataCreated'] != "0001-01-01T00:00:00"
          ? DateTime.tryParse(json['dataCreated'] as String)
          : null,
    );
  }
}

// -----------------------------------------------------------
// Platform
// -----------------------------------------------------------
class PlatformModel {
  final int oid;
  final String name;
  final bool active;
  final DateTime dateCreated;
  final DateTime dateModifire;
  final List<AuthorModel> autor;

  const PlatformModel({
    required this.oid,
    required this.name,
    required this.active,
    required this.dateCreated,
    required this.dateModifire,
    required this.autor,
  });

  factory PlatformModel.fromJson(Map<String, dynamic> json) {
    final autorList =
        (json['autor'] as List<dynamic>?)
            ?.map((e) => AuthorModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return PlatformModel(
      oid: json['oid'] as int,
      name: json['name'] as String,
      active: json['active'] as bool,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      dateModifire: DateTime.parse(json['dateModifire'] as String),
      autor: autorList,
    );
  }

  Map<String, dynamic> toJson() => {
    'oid': oid,
    'name': name,
    'active': active,
    'dateCreated': dateCreated.toIso8601String(),
    'dateModifire': dateModifire.toIso8601String(),
    'autor': autor.map((e) => e.toJson()).toList(),
  };
}

// -----------------------------------------------------------
// Company
// -----------------------------------------------------------
class CompanyModel {
  final int oid;
  final String name;
  final String? idnp;
  final int companyStateOid;
  final String companyStateName;
  final bool active;
  final DateTime dateModifire;
  final DateTime dateCreated;
  final List<PlatformModel> platforms;

  const CompanyModel({
    required this.oid,
    required this.name,
    required this.idnp,
    required this.companyStateOid,
    required this.companyStateName,
    required this.active,
    required this.dateModifire,
    required this.dateCreated,
    required this.platforms,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    final platformList =
        (json['platforms'] as List<dynamic>?)
            ?.map((e) => PlatformModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return CompanyModel(
      oid: json['oid'] as int,
      name: json['name'] as String,
      idnp: json['idnp'] as String?,
      companyStateOid: json['companyStateOid'] as int,
      companyStateName: json['companyStateName'] as String,
      active: json['active'] as bool,
      dateModifire: DateTime.parse(json['dateModifire'] as String),
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      platforms: platformList,
    );
  }

  Map<String, dynamic> toJson() => {
    'oid': oid,
    'name': name,
    'idnp': idnp,
    'companyStateOid': companyStateOid,
    'companyStateName': companyStateName,
    'active': active,
    'dateModifire': dateModifire.toIso8601String(),
    'dateCreated': dateCreated.toIso8601String(),
    'platforms': platforms.map((e) => e.toJson()).toList(),
  };

  /// Парсинг списка компаний из JSON-массива
  static List<CompanyModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => CompanyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
