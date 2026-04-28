import 'package:service_desk/models/tikets_models/tiket_response.dart';

abstract class TicketEvent {}

class LoadTickets extends TicketEvent {}


class AddTicket extends TicketEvent {
  final TicketResponse ticket;  // твой класс Ticket
  AddTicket(this.ticket);
}
