import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:service_desk/const/const_app.dart';

import '../models/tikets_models/tiket_phone_model.dart';

class TicketPhoneService {


  Future<List<TicketPhoneModel>> getByTicket({required String apiKey, required int ticketId}) async {
    final uri = Uri.parse(
      '$url/TicketPhone/GetByTicketTicketPhone'
          '?ticketId=$ticketId',
    );

    final response = await http.get(uri, headers: {
      "Content-Type": "application/json",
      "X-API-KEY": apiKey,
    });

    if (response.statusCode != 200) {
      throw Exception(
        'Ошибка загрузки звонков: '
            '${response.statusCode} ${response.body}',
      );
    }

    final dynamic data = jsonDecode(response.body);

    if (data is! List) {
      throw Exception('Некорректный формат ответа');
    }

    return data.map(
          (item) => TicketPhoneModel.fromJson(
        item as Map<String, dynamic>,)).toList();
  }
}