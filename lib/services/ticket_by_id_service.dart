import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:service_desk/models/tikets_models/tiket_paging_response.dart';

import '../const/const_app.dart';
import '../models/tikets_models/tiket_response.dart';

class TicketByIdService{

  Future<List<TicketResponse>> getTicketById({required String apiKey, required int user}) async {
    final uri = Uri.parse('$url/Tiket/GetTicketByUserId').replace(
      queryParameters: {'userId': user.toString()},
    );
    print(user);
    final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${apiKey}",
        }
    );
    if (response.statusCode == 200) {
      final List<dynamic>  jsonList = jsonDecode(response.body);
      return jsonList.map((json) =>
          TicketResponse.fromJson(json)).toList();

    } else {
      throw Exception('Ошибка загрузки тикетов: ${response.statusCode}');
    }
  }
}