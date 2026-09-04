// -----------------------------------------------------------
// SubCategory (создание, соответствует SubCategoryDto)
// -----------------------------------------------------------
class SubCategoryCreateModel {
  final int oid;
  final String name;
  final bool active;
  final int categoryOid;

  const SubCategoryCreateModel({
    this.oid = 0,
    required this.name,
    this.active = true,
    required this.categoryOid,
  });

  factory SubCategoryCreateModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryCreateModel(
      oid: json['oid'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      active: json['active'] as bool? ?? true,
      categoryOid: json['categoryOid'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'oid': oid,
    'name': name,
    'active': active,
    'categoryOid': categoryOid,
  };
}
