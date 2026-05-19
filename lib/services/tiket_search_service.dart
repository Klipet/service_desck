import 'dart:convert';

import 'package:http/http.dart' as http;

import '../const/const_app.dart';
import '../models/tikets_models/tiket_response.dart';

class TicketSearchService{

  Future<List<TicketResponse>> getTicketSearch({required String apiKey, required String query}) async {

    final uri = Uri.parse('$url/Tiket/GetSearch').replace(
      queryParameters: {'search': query},
    );
    final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${apiKey}",
        }
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) =>
          TicketResponse.fromJson(json)).toList();

    } else {
      throw Exception('Ошибка загрузки тикетов: ${response.statusCode}');
    }
  }
}