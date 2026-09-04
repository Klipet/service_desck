import 'dart:convert';

import 'package:http/http.dart' as http;

import '../const/const_app.dart';
import '../models/dictionary_models/simple_dictionary_model.dart';

class TiketTypeService {
  Future<List<SimpleDictionaryModel>> getAllTiketTypes({
    required String apiKey,
  }) async {
    final uri = Uri.parse('$url/TiketType/AllTiketType');

    final response = await http.get(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((e) => SimpleDictionaryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Ошибка загрузки типов заявок: ${response.statusCode}');
    }
  }

  Future<SimpleDictionaryModel> updateTiketType({
    required String apiKey,
    required SimpleDictionaryModel tiketType,
  }) async {
    final uri = Uri.parse('$url/TiketType/UpadateTiketTypeById')
        .replace(queryParameters: {'id': tiketType.oid.toString()});

    final response = await http.put(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
      body: jsonEncode(tiketType.toJson()),
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) return tiketType;
      return SimpleDictionaryModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ошибка обновления типа заявки: ${response.statusCode}');
    }
  }

  Future<SimpleDictionaryModel> createTiketType({
    required String apiKey,
    required String name,
  }) async {
    final uri = Uri.parse('$url/TiketType/NewTiketType');
    final now = DateTime.now();

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
      body: jsonEncode({
        "name": name,
        "active": true,
        "dateCreated": now.toIso8601String(),
        "dateModifire": now.toIso8601String(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        return SimpleDictionaryModel(name: name, dateCreated: now, dateModifire: now);
      }
      return SimpleDictionaryModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ошибка создания типа заявки: ${response.statusCode}');
    }
  }
}
