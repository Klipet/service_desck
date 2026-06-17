import 'dart:io';

import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

import '../blocs/tiket_blocs/tiket_bloc.dart';
import '../blocs/tiket_blocs/tiket_event.dart';
import '../data_base/user_repository.dart';
import '../models/ticket_message/ticket_comment_model.dart';
import '../models/tikets_models/tiket_response.dart';
import '../utils/notification_windows.dart';

class HubConnecterR {
  // ---- Singleton ----
  static HubConnecterR? _instance;

  static HubConnecterR init(TicketBloc ticketBloc) {
    _instance ??= HubConnecterR._internal(ticketBloc);
    return _instance!;
  }

  static HubConnecterR get instance {
    if (_instance == null) {
      throw StateError(
        'HubConnecterR не инициализирован. Сначала вызовите HubConnecterR.init(ticketBloc).',
      );
    }
    return _instance!;
  }
  // --------------------

  final TicketBloc ticketBloc;
  late HubConnection hubConnection;
  bool _isConnected = false;
  final user = UserRepository();

  HubConnecterR._internal(this.ticketBloc);

  String get _baseUrl {
   return 'https://dev-servicedesk.edi.md';
  }

  //'http://localhost:5000'
 // 'https://dev-servicedesk.edi.md'
  Future<void> startWithAutoReconnect() async {
    await _setupHandlers();
    ticketBloc.add(FetchAllMessages());
    while (true) {
      if (!_isConnected) {
        await _tryConnect();
      }
      await Future.delayed(Duration(seconds: 5));
    }
  }

  Future<void> _tryConnect() async {
    try {
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

  Future<void> restartConnection() async {
    try {
      if (hubConnection.state == HubConnectionState.Connected) {
        await hubConnection.stop();
      }
    } catch (_) {}
    _isConnected = false;
    await _setupHandlers();
    await _tryConnect();
  }

  Future<void> _setupHandlers() async {
    final apiKey = await user.getUserApikey();
    hubConnection = HubConnectionBuilder()
        .withUrl(
      "$_baseUrl/ticketHub?access_token=${apiKey ?? ''}",)
        .build();

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
        final ticket = TicketMessageModel.fromJson(args[0] as Map<String, dynamic>);
        ticketBloc.add(AddComment(ticket));
        ticketBloc.add(FetchAllMessages());
        print('✅ новый NewComment');
      }
    });
  }
}
