import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:service_desk/models/company_model.dart';

import '../const/const_app.dart';

class ClientService{

  Future<List<CompanyModel>> getCompany({required String apiKey}) async{
    final uri = Uri.parse('$url/Company');
    final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": apiKey,
        }
    );
    if (response.statusCode == 200) {
      final List<dynamic>  jsonList = jsonDecode(response.body);
      return jsonList.map((json) =>
          CompanyModel.fromJson(json)).toList();
    } else {
      throw Exception('Ошибка загрузки тикетов: ${response.statusCode}');
    }
  }
}