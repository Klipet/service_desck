part of 'ticket_detail_bloc.dart';

@immutable
sealed class TicketDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class TicketDetailByIdSearch extends TicketDetailEvent{
  final int? search;
  TicketDetailByIdSearch(this.search);

  @override
  List<Object?> get props => [search];
}

class ResetDetailTicket extends TicketDetailEvent {}

