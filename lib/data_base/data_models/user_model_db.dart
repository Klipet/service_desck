
import 'package:isar/isar.dart';

import 'user_model_permisions_db.dart';

part 'user_model_db.g.dart';

@collection
class UserModelDB {
  Id id = Isar.autoIncrement;
  late String login;
  late String password;
  late bool autoSavePassword;
  late String apiKey;
  late String userName;
  late int userId;
  final permissions = IsarLinks<UserModelPermissionsDB>();

}