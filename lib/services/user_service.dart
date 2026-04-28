import 'package:hive/hive.dart';

import '../data_base/user_model.dart';

class UserService {
  static const _boxName = 'userBox';

  // Открыть box
  static Future<Box<UserModel>> openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<UserModel>(_boxName); // 👈 возвращает уже открытый
    }
    return await Hive.openBox<UserModel>(_boxName);
  }

  // Сохранить / обновить пользователя
  static Future<void> saveUser(UserModel user) async {
    final box = await openBox();
    await box.put('user', user); // один ключ — один пользователь
  }

  // Получить пользователя
  static UserModel? getUser() {
    final box = Hive.box<UserModel>(_boxName);
    return box.get('user');
  }

  // Удалить пользователя
  static Future<void> deleteUser() async {
    final box = Hive.box<UserModel>(_boxName);
    await box.delete('user');
  }
}