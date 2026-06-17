import 'package:windows_notification/notification_message.dart';
import 'package:windows_notification/windows_notification.dart';

import '../models/ticket_message/ticket_comment_model.dart';
import '../models/tikets_models/tiket_response.dart';


final _winNotify = WindowsNotification(
  applicationId: 'com.example.service_desk',
);
class NotificationWindows{



  void showTicketNotification(TicketResponse ticket) {

    final template = '''
<toast>
  <visual>
    <binding template="ToastGeneric">
      <text>🔔 Новая заявка ${ticket.id}</text>
      <text>Компания: ${ticket.companyName}</text>
      <text>${ticket.title}</text>
      <text placement="attribution">Система ServiceDesk</text>
      <image src="C:\\path\\to\\logo.png" placement="appLogoOverride" hint-crop="circle"/>
    </binding>
  </visual>
  <actions>
    <action content="✅ Принять" arguments="accept_${ticket.id}"/>
    <action content="❌ Закрыть" arguments="dismiss"/>
  </actions>
  <audio src="ms-winsoundevent:Notification.Mail"/>
</toast>
    ''';
    final message = NotificationMessage.fromCustomTemplate(
      '${ticket.id}',
      group: 'tickets',
    );
    _winNotify.showNotificationCustomTemplate(message, template);
  }


  void showCommentNotification(TicketMessageModel ticket) {

    final template = '''
<toast>
  <visual>
    <binding template="ToastGeneric">
      <image src="D:\\AppProject\\service_desk\\assets\\image\\big_logo.png" placement="appLogoOverride" hint-crop="circle"/>
      <text>Заявка #${ticket.ticketId}</text>
      <text>📩 ${ticket.messageText}</text>
      <text placement="attribution">ServiceDesk</text>
    </binding>
  </visual>
  <actions>
    <action content="Открыть" arguments="open_${ticket.id}"/>
    <action content="Закрыть" arguments="dismiss"/>
  </actions>
</toast>
    ''';
    final message = NotificationMessage.fromCustomTemplate(
      '${ticket.id}',
      group: 'tickets',
    );
    _winNotify.showNotificationCustomTemplate(message, template);
  }

  void showNotificationConnect(String state) {

    final template = '''
<toast>
  <visual>
    <binding template="ToastGeneric">
      <image src="D:\\AppProject\\service_desk\\assets\\image\\big_logo.png" placement="appLogoOverride" hint-crop="circle"/>
      <text>Сервис SignalR</text>
      <text>Текуший Статус: ${state}</text>
      <text placement="attribution">ServiceDesk</text>
    </binding>
  </visual>
</toast>
    ''';
    final message = NotificationMessage.fromCustomTemplate(
      '${state}',
      group: 'tickets',
    );
    _winNotify.showNotificationCustomTemplate(message, template);
  }

}