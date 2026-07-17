import 'dart:convert';

import 'package:http/http.dart' as http;

import '../const/const_app.dart';
import '../models/company_model.dart';

class CompanyService {


  Future<List<CompanyModel>> searchCompanies({
    required String apiKey,
    required String query,
    int take = 20,
  }) async {
    final uri = Uri.parse('$url/Company/Search').replace(
      queryParameters: {
        'query': query,
        'take': take.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList =
      jsonDecode(response.body) as List<dynamic>;
      return CompanyModel.fromJsonList(jsonList);
    } else {
      throw Exception('Ошибка поиска компаний: ${response.statusCode}');
    }
  }
}