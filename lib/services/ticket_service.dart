import 'dart:convert';

import 'package:service_desk/models/users_models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../const/const_app.dart';
import '../models/tikets_models/tiket_response.dart';
import 'package:http/http.dart' as http;

class TicketService{
  Future<List<TicketResponse>> getTikets({required String apiKey}) async {

    final response = await http.get(
      Uri.parse("$url/Tiket/GetAllTicket"),
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

  Future<TicketResponse> tiketById({required int ticketId, required String apiKey}) async{
    final uri = Uri.parse('$url/Tiket/GetTicketById').replace(
      queryParameters: {'id': ticketId.toString()},
    );
    final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${apiKey}",
        }
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return TicketResponse.fromJson(json);

    } else {
      throw Exception('Ошибка загрузки тикетов: ${response.statusCode}');
    }
  }
}