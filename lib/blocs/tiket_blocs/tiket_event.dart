import 'package:service_desk/models/tiket_comment/ticket_comment_model.dart';
import 'package:service_desk/models/tikets_models/tiket_response.dart';

import '../../screens/tikets/tikets_widgets/ticket_tab_filter.dart';

abstract class TicketEvent {}

class LoadTickets extends TicketEvent {}


class AddTicket extends TicketEvent {
  final TicketResponse ticket;  // твой класс Ticket
  AddTicket(this.ticket);
}

class AddComment extends TicketEvent{
  final TicketCommentModel ticketModel;
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

class LoadMyTickets extends TicketEvent {}
