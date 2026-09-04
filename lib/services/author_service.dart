import 'dart:convert';

import 'package:http/http.dart' as http;

import '../const/const_app.dart';
import '../models/author_models/author_create_model.dart';

class AuthorService {
  Future<List<AuthorCreateModel>> getAllAuthors({
    required String apiKey,
  }) async {
    final uri = Uri.parse('$url/Author/GetAllAuthor');

    final response = await http.get(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList =
      jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((e) => AuthorCreateModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Ошибка загрузки авторов: ${response.statusCode}');
    }
  }

  Future<AuthorCreateModel> createAuthor({
    required String apiKey,
    required AuthorCreateModel author,
  }) async {
    final uri = Uri.parse('$url/Author/CreateAuthor');

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
      body: jsonEncode(author.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) return author;
      return AuthorCreateModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Ошибка создания автора: ${response.statusCode}');
    }
  }
}
