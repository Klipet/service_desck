import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'data_models/user_model_db.dart';
import 'data_models/user_model_permisions_db.dart';



class InitIsar{
  static Isar? _isar;

  static Future<Isar> init() async {
    if (_isar != null) return _isar!;

    final dir = File(Platform.resolvedExecutable).parent.path;
    _isar = await Isar.open(
      [UserModelDBSchema, UserModelPermissionsDBSchema],
      directory: dir,
      name: 'app_db',
    );
    return _isar!;
  }
}