class PlatformModel {
  final int oid;
  final String name;
  final bool active;
  final DateTime dateCreated;
  final DateTime dateModifire;

  PlatformModel({
    required this.oid,
    required this.name,
    required this.active,
    required this.dateCreated,
    required this.dateModifire,
  });

  factory PlatformModel.fromJson(Map<String, dynamic> json) {
    return PlatformModel(
      oid: json['oid'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      active: json['active'] as bool? ?? false,
      dateCreated: DateTime.tryParse(json['dateCreated'] as String? ?? '') ??
          DateTime.now(),
      dateModifire: DateTime.tryParse(json['dateModifire'] as String? ?? '') ??
          DateTime.now(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'oid': oid,
      'name': name,
      'active': active,
      'dateCreated': dateCreated.toIso8601String(),
      'dateModifire': dateModifire.toIso8601String(),
    };
  }
}