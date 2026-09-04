import 'dart:convert';

import 'package:http/http.dart' as http;

import '../const/const_app.dart';
import '../models/holiday_models/holiday_create_model.dart';

class HolidayService {
  Future<List<HolidayCreateModel>> getAllHolidays({
    required String apiKey,
  }) async {
    final uri = Uri.parse('$url/Settings/Holiday');

    final response = await http.get(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((e) => HolidayCreateModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Ошибка загрузки праздников: ${response.statusCode}');
    }
  }

  Future<HolidayCreateModel> createHoliday({
    required String apiKey,
    required HolidayCreateModel holiday,
  }) async {
    final uri = Uri.parse('$url/Settings/Holiday');

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
      body: jsonEncode(holiday.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) return holiday;
      return HolidayCreateModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Ошибка создания праздника: ${response.statusCode}');
    }
  }
}
