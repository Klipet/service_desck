part of 'ticket_detail_bloc.dart';

@immutable
sealed class TicketDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class TicketDetailInitial extends TicketDetailState {}

class TicketDetailLoading extends TicketDetailState {}

class TicketDetailLoaded extends TicketDetailState {
  final TicketResponse ticket;

  TicketDetailLoaded(this.ticket);

  @override
  List<Object?> get props => [ticket];
}

class TicketDetailError extends TicketDetailState {
  final String message;

  TicketDetailError(this.message);

  @override
  List<Object?> get props => [message];
}