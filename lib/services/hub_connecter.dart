import 'package:service_desk/models/tiket_comment/ticket_comment_model.dart';
import 'package:service_desk/services/user_service.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

import '../blocs/tiket_blocs/tiket_bloc.dart';
import '../blocs/tiket_blocs/tiket_event.dart';
import '../models/tikets_models/tiket_response.dart';
import '../utils/notification_windows.dart';

class HubConnecterR {
  final TicketBloc ticketBloc;
  late HubConnection hubConnection;

  HubConnecterR(this.ticketBloc);

  Future<void> connectToSignalR() async {
    String apikey;
    var userInfo = UserService.getUser();
    apikey = userInfo?.apiKey ?? '';

    hubConnection = HubConnectionBuilder()
        .withUrl("http://localhost:5000/ticketHub?access_token=$apikey")
        .build();

    hubConnection.on("NewTicketCreated", (args) {
      print("📡 SignalR событие пришло: $args");
      if (args != null && args.isNotEmpty) {
        final ticket = TicketResponse.fromJson(
          args[0] as Map<String, dynamic>,
        );

        ticketBloc.add(AddTicket(ticket)); // ✅ без context
        NotificationWindows().showTicketNotification(ticket);
        print('✅ новый тикет');
      }
    });

    hubConnection.on("NewComment", (args) {
      print("📡 SignalR событие пришло: $args");
      if (args != null && args.isNotEmpty) {
        final ticket = TicketCommentModel.fromJson(
          args[0] as Map<String, dynamic>,
        );

       ticketBloc.add(AddComment(ticket)); // ✅ без context
      //  NotificationWindows().showTicketNotification(ticket!);
        print('✅ новый NewComment');
      }
    });

    await hubConnection.start();
    print("✅ SignalR подключен");
  }
}
