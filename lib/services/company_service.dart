import 'dart:convert';

import 'package:http/http.dart' as http;

import '../const/const_app.dart';
import '../models/company_model.dart';

class CompanyService {

  Future<List<CompanyModel>> getAllCompanies({
    required String apiKey,
  }) async {
    final uri = Uri.parse('$url/Company');

    final response = await http.get(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList =
      jsonDecode(response.body) as List<dynamic>;
      return CompanyModel.fromJsonList(jsonList);
    } else {
      throw Exception('Ошибка загрузки компаний: ${response.statusCode}');
    }
  }

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

  Future<List<CompanyStateModel>> getCompanyStates({
    required String apiKey,
  }) async {
    final uri = Uri.parse('$url/CompanyState/AllCompanyState');

    final response = await http.get(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList =
      jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((e) => CompanyStateModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Ошибка загрузки статусов компании: ${response.statusCode}');
    }
  }

  Future<CompanyModel> createCompany({
    required String apiKey,
    required String name,
    required int companyStateOid,
    String? idnp,
  }) async {
    final uri = Uri.parse('$url/Company');

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
      body: jsonEncode({
        "name": name,
        "idnp": idnp,
        "active": true,
        "comapnyStateOid": companyStateOid,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        return CompanyModel(
          oid: 0,
          name: name,
          idnp: idnp,
          companyStateOid: companyStateOid,
          companyStateName: '',
          active: true,
          dateModifire: DateTime.now(),
          dateCreated: DateTime.now(),
          platforms: const [],
        );
      }
      return CompanyModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ошибка создания компании: ${response.statusCode}');
    }
  }

  Future<CompanyModel> updateCompany({
    required String apiKey,
    required CompanyModel company,
  }) async {
    final uri = Uri.parse('$url/Company/UpdateCompanyById')
        .replace(queryParameters: {'id': company.oid.toString()});

    final response = await http.put(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
      body: jsonEncode(company.toJson()),
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) return company;
      return CompanyModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ошибка обновления компании: ${response.statusCode}');
    }
  }
}