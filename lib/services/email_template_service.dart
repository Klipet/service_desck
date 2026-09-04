import 'dart:convert';

import 'package:http/http.dart' as http;

import '../const/const_app.dart';
import '../models/email_template_models/email_template_create_model.dart';
import '../models/email_template_models/email_template_list_model.dart';

class EmailTemplateService {
  Future<void> createEmailTemplate({
    required String apiKey,
    required EmailTemplateCreateModel template,
  }) async {
    final uri = Uri.parse('$url/EmailTemplate/NewTempalte');

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
      body: jsonEncode(template.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Ошибка создания email-шаблона: ${response.statusCode}');
    }
  }

  Future<List<EmailTemplateListModel>> getAllTemplates({
    required String apiKey,
  }) async {
    final uri = Uri.parse('$url/EmailTemplate/GetAllTemplate');

    final response = await http.get(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((e) =>
              EmailTemplateListModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Ошибка загрузки шаблонов: ${response.statusCode}');
    }
  }

  Future<void> updateTemplate({
    required String apiKey,
    required EmailTemplateCreateModel template,
  }) async {
    final uri = Uri.parse('$url/EmailTemplate/UpdateTemplate')
        .replace(queryParameters: {'id': template.oid.toString()});

    final response = await http.put(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
      body: jsonEncode(template.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Ошибка обновления шаблона: ${response.statusCode}');
    }
  }

  Future<void> deleteTemplate({
    required String apiKey,
    required int oid,
  }) async {
    final uri = Uri.parse('$url/EmailTemplate/DeleteTemplate')
        .replace(queryParameters: {'id': oid.toString()});

    final response = await http.delete(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Ошибка удаления шаблона: ${response.statusCode}');
    }
  }
}
