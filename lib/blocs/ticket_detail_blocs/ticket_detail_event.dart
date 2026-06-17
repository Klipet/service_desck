part of 'ticket_detail_bloc.dart';

@immutable
sealed class TicketDetailEvent {}

class TicketDetailByIdSearch extends TicketDetailEvent{
  final int? search;
  TicketDetailByIdSearch(this.search);
}

class ResetDetailTicket extends TicketDetailEvent {}

