
import 'package:service_desk/models/tikets_models/tiket_response.dart';

import '../../models/ticket_message/ticket_comment_model.dart';
import '../../screens/tikets/tikets_widgets/ticket_tab_filter.dart';

abstract class TicketEvent {}

class LoadTickets extends TicketEvent {}


class AddTicket extends TicketEvent {
  final TicketResponse ticket;  // твой класс Ticket
  AddTicket(this.ticket);
}

class AddComment extends TicketEvent{
  final TicketMessageModel ticketModel;
  AddComment(this.ticketModel);
}


class TicketSearch extends TicketEvent{
  final String? search;
  TicketSearch(this.search);
}

class TicketByIdSearch extends TicketEvent{
  final int? search;
  TicketByIdSearch(this.search);
}

class ResetTicket extends TicketEvent {
  @override
  List<Object> get props => [];
}

class MenageTickets extends TicketEvent {
  final int primoryTiket;
  final List<int> secondariTikets;
  MenageTickets({required this.primoryTiket, required this.secondariTikets});

  @override
  List<Object> get props => [];
}

class LoadMyTickets extends TicketEvent {}

class FetchAllMessages extends TicketEvent {}
