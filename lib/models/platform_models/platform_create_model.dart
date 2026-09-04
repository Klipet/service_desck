// -----------------------------------------------------------
// Platform (создание, соответствует PlatformPostDto из /Platform/NewPlatform)
// -----------------------------------------------------------
class PlatformCreateModel {
  final int oid;
  final String name;
  final bool active;
  final DateTime dateCreated;
  final DateTime dateModifire;
  final int companyId;

  const PlatformCreateModel({
    this.oid = 0,
    required this.name,
    this.active = true,
    required this.dateCreated,
    required this.dateModifire,
    required this.companyId,
  });

  factory PlatformCreateModel.fromJson(Map<String, dynamic> json) {
    return PlatformCreateModel(
      oid: json['oid'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      active: json['active'] as bool? ?? true,
      dateCreated:
          DateTime.tryParse(json['dateCreated'] as String? ?? '') ??
              DateTime.now(),
      dateModifire:
          DateTime.tryParse(json['dateModifire'] as String? ?? '') ??
              DateTime.now(),
      companyId: json['companyId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'oid': oid,
    'name': name,
    'active': active,
    'dateCreated': dateCreated.toIso8601String(),
    'dateModifire': dateModifire.toIso8601String(),
    'companyId': companyId,
  };
}
