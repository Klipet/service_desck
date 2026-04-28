import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String login;

  @HiveField(1)
  String password;

  @HiveField(2)
  bool autoSavePassword;

  @HiveField(3)
  String apiKey;

  @HiveField(4)
  String userName;

  @HiveField(5)
  int userId;

  UserModel({
    required this.login,
    required this.password,
    required this.autoSavePassword,
    required this.apiKey,
    required this.userName,
    required this.userId
  });
}