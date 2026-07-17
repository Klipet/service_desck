import 'package:service_desk/models/tikets_models/tiket_post_model.dart';
import 'package:service_desk/models/tikets_models/tiket_response.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../const/const_app.dart';


class TiketPostService{


  Future<TicketResponse> tiketPost({required TicketPostModel model, required String apiKey})async{
    final uri = Uri.parse('$url/Tiket/NewTicket');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': apiKey,
      },
      body: jsonEncode(model.toJson()),
    );
    if (response.statusCode == 200) {
      return TicketResponse.fromJson(
        jsonDecode(response.body),
      );
    }
    String detail = 'Неизвестная ошибка';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['detail'] != null) {
        detail = decoded['detail'].toString();
      }
    } catch (_) {
      throw Exception(detail);
      // тело не JSON — оставляем detail по умолчанию
    }
    throw Exception(detail);
  }
}