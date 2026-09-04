import 'dart:convert';

import 'package:http/http.dart' as http;

import '../const/const_app.dart';
import '../models/user_create_models/user_create_model.dart';
import '../models/user_create_models/user_list_model.dart';

class UserCreateService {
  Future<List<UserListModel>> getAllUsers({
    required String apiKey,
  }) async {
    final uri = Uri.parse('$url/User');

    final response = await http.get(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((e) => UserListModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Ошибка загрузки пользователей: ${response.statusCode}');
    }
  }

  /// [password] передавай только если пользователь ввёл новый пароль —
  /// null означает "не менять пароль" и ключ password не уйдёт в теле запроса.
  /// ВНИМАНИЕ: это предположение о поведении бэка не проверено — сервер может
  /// трактовать отсутствие поля иначе. Проверь перед реальным использованием.
  Future<void> updateUser({
    required String apiKey,
    required int oid,
    required String name,
    required String firstName,
    required String email,
    required String loghin,
    required bool isActive,
    required DateTime dateCreated,
    required int workSpaceId,
    String? phone,
    String? password,
  }) async {
    final uri = Uri.parse('$url/User/UpdateUser')
        .replace(queryParameters: {'id': oid.toString()});

    final body = <String, dynamic>{
      'name': name,
      'firstName': firstName,
      'email': email,
      'phone': phone,
      'loghin': loghin,
      'isActive': isActive,
      'dateCreated': dateCreated.toIso8601String(),
      'workSpaceId': workSpaceId,
    };
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    final response = await http.put(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка обновления пользователя: ${response.statusCode}');
    }
  }

  Future<void> createUser({
    required String apiKey,
    required UserCreateModel user,
  }) async {
    final uri = Uri.parse('$url/User');

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Ошибка создания пользователя: ${response.statusCode}');
    }
  }
}
