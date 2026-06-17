import 'platform_model.dart';

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

  CompanyModel({
    required this.oid,
    required this.name,
    this.idnp,
    required this.companyStateOid,
    required this.companyStateName,
    required this.active,
    required this.dateModifire,
    required this.dateCreated,
    required this.platforms,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      oid: json['oid'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      idnp: json['idnp'] as String?,
      companyStateOid: json['companyStateOid'] as int? ?? 0,
      companyStateName: json['companyStateName'] as String? ?? '',
      active: json['active'] as bool? ?? false,
      dateModifire: DateTime.tryParse(json['dateModifire'] as String? ?? '') ??
          DateTime.now(),
      dateCreated: DateTime.tryParse(json['dateCreated'] as String? ?? '') ??
          DateTime.now(),
      platforms: (json['platforms'] as List<dynamic>?)
          ?.map((e) => PlatformModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'oid': oid,
      'name': name,
      'idnp': idnp,
      'comapnyStateOid': companyStateOid,
      'comapnyStateName': companyStateName,
      'active': active,
      'dateModifire': dateModifire.toIso8601String(),
      'dateCreated': dateCreated.toIso8601String(),
      'platforms': platforms.map((p) => p.toJson()).toList(),
    };
  }
}