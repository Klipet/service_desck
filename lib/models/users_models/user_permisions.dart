class UserPermissions {
  final int id;
  final String name;

  UserPermissions({required this.name, required this.id});

  factory UserPermissions.fromJson(Map<String, dynamic> json) {
    return UserPermissions(
        id: json["id"],
        name: json["name"]
    );
  }
}
