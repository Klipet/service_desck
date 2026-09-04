import 'dart:convert';

import 'package:http/http.dart' as http;

import '../const/const_app.dart';
import '../models/platform_models/platform_create_model.dart';

class PlatformService {
  Future<PlatformCreateModel> createPlatform({
    required String apiKey,
    required PlatformCreateModel platform,
  }) async {
    final uri = Uri.parse('$url/Platform/NewPlatform');

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json", "X-API-KEY": apiKey},
      body: jsonEncode(platform.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) return platform;
      return PlatformCreateModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Ошибка создания платформы: ${response.statusCode}');
    }
  }
}
