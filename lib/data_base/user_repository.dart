
import 'package:isar/isar.dart';
import 'package:service_desk/data_base/data_models/user_model_permisions_db.dart';
import 'package:service_desk/data_base/init_isar.dart';
import '../models/users_models/loghin_response.dart';
import '../models/users_models/user_model.dart';
import 'data_models/user_model_db.dart';


class UserRepository {

  // Сохранить / обновить пользователя
  Future<void> saveUser({required LoginResponse loginResponse,required bool autosave,required String password}) async {
    final isar = await InitIsar.init();

    final List<UserModelDB> dbListUser = [];
    final List<UserModelPermissionsDB> permisionList = [];

    final modelUser = await UserModelDB()
    ..id = 0
    ..userId = loginResponse.user.id
    ..apiKey = loginResponse.apikey
    ..userName = loginResponse.user.name
    ..autoSavePassword = autosave
      ..login = loginResponse.user.login
    ..password = password;

    final modelPermision = loginResponse.user.permissions.map((p) =>
       UserModelPermissionsDB()
         ..oid = p.id
        ..name = p.name
    ).toList();
    modelUser.permissions.addAll(modelPermision);

    dbListUser.add(modelUser);
    permisionList.addAll(modelPermision);
    await isar.writeTxn(() async {
      await isar.userModelDBs.putAll(dbListUser);
      await isar.userModelPermissionsDBs.putAll(permisionList);
      for(final dbPer in dbListUser){
        await dbPer.permissions.save();
      }
    });
  }

  Future <UserModelDB?> getUser() async {
    final isar = await InitIsar.init();
    final user = await isar.userModelDBs.where().findFirst();
    return user;
  }

  // Получить пользователя
  Future <int?> getUserId() async {
    final isar = await InitIsar.init();
    final user = await isar.userModelDBs.where().findFirst();
    return user?.id;
  }
  // Получить пользователя
  Future <String?> getUserApikey() async {
    final isar = await InitIsar.init();
    final user = await isar.userModelDBs.where().findFirst();
    return user?.apiKey;
  }

  Future <void> deletePermissions() async {
    final isar = await InitIsar.init();
    await isar.writeTxn(() async{
      await isar.userModelPermissionsDBs.clear();
    });
  }


  Future<List<UserModelPermissionsDB>> getPermissions() async {
    final isar = await InitIsar.init();
    final perm = await isar.userModelPermissionsDBs.where().findAll();
    return perm;
  }

}