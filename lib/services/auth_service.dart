import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:service_desk/const/const_app.dart';
import '../models/users_models/loghin_request.dart';
import '../models/users_models/loghin_response.dart';

class AuthService{

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse("$url/User/Auth"),
      headers: {
        "Content-Type": "application/json",
        "accept": "*/*"
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print(json);
      return LoginResponse.fromJson(json);
    } else {
      throw Exception("Ошибка авторизации: ${response.body}");
    }
  }
}
