import 'package:service_desk/models/users_models/user_permisions.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String login;
  final List<UserPermissions> permissions;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.login,
    required this.permissions,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      name: json["name"]?? '',
      email: json["email"]?? '',
      login: json["login"]?? '',
      permissions: (json["permissions"] as List<dynamic>)
        .map((e) => UserPermissions.fromJson(e))
        .toList(),
    );
  }
}