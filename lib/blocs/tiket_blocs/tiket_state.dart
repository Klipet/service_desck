import 'package:service_desk/models/tiket_comment/ticket_comment_model.dart';
import 'package:service_desk/models/tikets_models/tiket_response.dart';

abstract class TicketState {}

class TicketInitial extends TicketState {}

class TicketLoading extends TicketState {}

class TicketLoaded extends TicketState {
  final List<TicketResponse> tickets;
  final bool isNewTicket;
  final TicketResponse? newTicket;
  TicketLoaded(this.tickets, {this.isNewTicket = false, this.newTicket});
}

class TicketError extends TicketState {
  final String message;

  TicketError(this.message);
}

class CommentLoaded extends TicketState {
  final TicketCommentModel tickets;

  CommentLoaded(this.tickets);
}