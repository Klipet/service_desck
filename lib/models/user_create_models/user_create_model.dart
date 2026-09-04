// -----------------------------------------------------------
// User (создание, соответствует UserDto из POST /User)
// -----------------------------------------------------------
class UserCreateModel {
  final String name;
  final String firstName;
  final String email;
  final String password;
  final String? phone;
  final String loghin;
  final bool isActive;
  final DateTime dateCreated;
  final int workSpaceId;

  const UserCreateModel({
    required this.name,
    required this.firstName,
    required this.email,
    required this.password,
    this.phone,
    required this.loghin,
    this.isActive = true,
    required this.dateCreated,
    required this.workSpaceId,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'firstName': firstName,
    'email': email,
    'password': password,
    'phone': phone,
    'loghin': loghin,
    'isActive': isActive,
    'dateCreated': dateCreated.toIso8601String(),
    'workSpaceId': workSpaceId,
  };
}
