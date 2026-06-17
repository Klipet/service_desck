part of 'ticket_detail_bloc.dart';

@immutable
sealed class TicketDetailState {}

final class TicketDetailInitial extends TicketDetailState {}

class TicketDetailLoading extends TicketDetailState {}

class TicketDetailLoaded extends TicketDetailState {
  final TicketResponse ticket;

  TicketDetailLoaded(this.ticket);
}

class TicketDetailError extends TicketDetailState {
  final String message;

  TicketDetailError(this.message);
}