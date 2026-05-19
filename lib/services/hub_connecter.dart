import 'dart:io';

import 'package:service_desk/data_base/data_models/user_model_db.dart';
import 'package:service_desk/models/tiket_comment/ticket_comment_model.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

import '../blocs/tiket_blocs/tiket_bloc.dart';
import '../blocs/tiket_blocs/tiket_event.dart';
import '../data_base/user_repository.dart';
import '../models/tikets_models/tiket_response.dart';
import '../utils/notification_windows.dart';

class HubConnecterR {
  final TicketBloc ticketBloc;
  late HubConnection hubConnection;
  bool _isConnected = false;
  final user = UserRepository();
  HubConnecterR(this.ticketBloc);

  String get _baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:5000';
    return 'http://localhost:5000';
  }

  // Запускаем и постоянно следим за соединением
  Future<void> startWithAutoReconnect() async {
   await _setupHandlers();

    while (true) {
      if (!_isConnected) {
        await _tryConnect();
      }
      await Future.delayed(Duration(seconds: 50)); // проверяем каждые 5 сек
    }
  }

  Future<void> _tryConnect() async {
    try {
      // Если хаб уже существует и не disconnected — пропускаем
      if (hubConnection.state == HubConnectionState.Connected) {
        _isConnected = true;
        return;
      }

      await hubConnection.start();
      _isConnected = true;
      NotificationWindows().showNotificationConnect('✅ SignalR подключен');
      print("✅ SignalR подключен");
    } catch (e) {
      _isConnected = false;
      print("⚠️ SignalR недоступен, повтор через 50 сек... $e");
    }
  }

  Future<void> _setupHandlers() async {
    final apiKey = await user.getUser();
    hubConnection = HubConnectionBuilder()
        .withUrl("$_baseUrl/ticketHub?access_token=${apiKey?.apiKey ?? ''}")
        .build();

    // Следим за разрывом соединения
    hubConnection.onclose((error) {
      _isConnected = false;
      NotificationWindows().showNotificationConnect('🔴 SignalR отключился');
      print("🔴 SignalR отключился: $error");
    });

    hubConnection.on("NewTicketCreated", (args) {
      if (args != null && args.isNotEmpty) {
        final ticket = TicketResponse.fromJson(args[0] as Map<String, dynamic>);
        ticketBloc.add(AddTicket(ticket));
        NotificationWindows().showTicketNotification(ticket);
        print('✅ новый тикет');
      }
    });

    hubConnection.on("NewComment", (args) {
      if (args != null && args.isNotEmpty) {
        final ticket = TicketCommentModel.fromJson(args[0] as Map<String, dynamic>);
        ticketBloc.add(AddComment(ticket));
        print('✅ новый NewComment');
      }
    });
  }
}
