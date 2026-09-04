import 'package:equatable/equatable.dart';

import 'package:service_desk/models/tikets_models/tiket_response.dart';
import '../../models/ticket_message/ticket_comment_model.dart';

import '../../models/tikets_models/ticket_marge_model.dart';
import '../../screens/tikets/tikets_widgets/ticket_tab_filter.dart';

abstract class TicketState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TicketInitial extends TicketState {}

class TicketLoading extends TicketState {}

class TicketLoaded extends TicketState {
  final List<TicketResponse> tickets;
  final bool isNewTicket;
  final TicketTabFilter activeTab; // ✅ добавь

  final TicketResponse? newTicket;
  TicketLoaded(this.tickets, {this.isNewTicket = false, this.newTicket, this.activeTab = TicketTabFilter.all });

  @override
  List<Object?> get props => [tickets, isNewTicket, activeTab, newTicket];
}

class TicketError extends TicketState {
  final String message;

  TicketError(this.message);

  @override
  List<Object?> get props => [message];
}

class CommentLoaded extends TicketState {
  final TicketMessageModel tickets;

  CommentLoaded(this.tickets);

  @override
  List<Object?> get props => [tickets];
}
class TicketByIdLoaded extends TicketState {
  final TicketResponse tickets;

  TicketByIdLoaded(this.tickets);

  @override
  List<Object?> get props => [tickets];
}


class TicketMargetSuccess extends TicketState {
  final MergeTicketResponse tickets;

  TicketMargetSuccess(this.tickets);

  @override
  List<Object?> get props => [tickets];
}
class TicketMargetError extends TicketState {
  final MergeTicketResponse tickets;

  TicketMargetError(this.tickets);

  @override
  List<Object?> get props => [tickets];
}


class TicketMessageLoaded extends TicketState {
  final List<TicketMessageModel> messages;
  final int unreadCount;

  TicketMessageLoaded({required this.messages})
      : unreadCount = messages.where((m) => !m.isRead).length;

  @override
  List<Object?> get props => [messages, unreadCount];
}

class TicketMessageError extends TicketState {
  final String message;
  TicketMessageError(this.message);

  @override
  List<Object?> get props => [message];
}
class MessageLoad extends TicketState {
}
