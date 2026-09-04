import 'dart:convert';

import 'package:http/http.dart' as http;

import '../const/const_app.dart';
import '../models/dictionary_models/simple_dictionary_model.dart';

/// CRUD-сервис для справочника CompanyState (админ-страница создания).
/// Не путать с CompanyService.getCompanyStates — тот только читает список
/// для выпадающего списка при создании компании.
class CompanyStateService {
  Future<List<SimpleDictionaryModel>> getAllCompanyStates({
    required String apiKey,
  }) async {
    final uri = Uri.parse('$url/CompanyState/AllCompanyState');

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
      throw Exception('Ошибка загрузки статусов компании: ${response.statusCode}');
    }
  }

  Future<SimpleDictionaryModel> updateCompanyState({
    required String apiKey,
    required SimpleDictionaryModel companyState,
  }) async {
    final uri = Uri.parse('$url/CompanyState/UpadateCompanyStateById')
        .replace(queryParameters: {'id': companyState.oid.toString()});

    final response = await http.put(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
      body: jsonEncode({
        ...companyState.toJson(),
        "companyStateName": companyState.name,
        "companyStateOid": companyState.oid,
      }),
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) return companyState;
      return SimpleDictionaryModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ошибка обновления статуса компании: ${response.statusCode}');
    }
  }

  Future<SimpleDictionaryModel> createCompanyState({
    required String apiKey,
    required String name,
  }) async {
    final uri = Uri.parse('$url/CompanyState/NewCompanyState');
    final now = DateTime.now();

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
      body: jsonEncode({
        "name": name,
        "active": true,
        "dateCreated": now.toIso8601String(),
        "dateModifire": now.toIso8601String(),
        // CompanyStateDto на бэке дублирует name/oid в companyStateName/
        // companyStateOid (баг схемы) — зеркалим на всякий случай.
        "companyStateName": name,
        "companyStateOid": 0,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        return SimpleDictionaryModel(name: name, dateCreated: now, dateModifire: now);
      }
      return SimpleDictionaryModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ошибка создания статуса компании: ${response.statusCode}');
    }
  }
}
