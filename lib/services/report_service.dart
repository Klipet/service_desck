import 'dart:convert';

import 'package:http/http.dart' as http;

import '../const/const_app.dart';
import '../models/reports_model/report_post_model.dart';
import '../models/reports_model/report_response_model.dart';

class ReportService {
  Future<ReportResponseModel> generate({
    required ReportPostModel model,
    required String apiKey,
  }) async {
    final response = await http.post(
      Uri.parse("$url/Reports/run"),
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
      body: jsonEncode(model.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Ошибка ${response.statusCode}: ${response.body}');
    }

    return ReportResponseModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
