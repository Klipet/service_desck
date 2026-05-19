import 'package:isar/isar.dart';

part 'user_model_permisions_db.g.dart';


@collection
class UserModelPermissionsDB {
  Id id = Isar.autoIncrement;
  late int oid;
  late String name;

}