import 'dart:convert';

import 'package:http/http.dart' as http;

import '../const/const_app.dart';
import '../models/dictionary_item_model.dart';

class DictionaryService {
  Future<DictionariesResponse> getAllDictionaries({required String apiKey}) async {

    final response = await http.get(
      Uri.parse('$url/TotalTypeControler/TotalType'), // замени на реальный путь
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load dictionaries: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return DictionariesResponse.fromJson(json);
  }
}