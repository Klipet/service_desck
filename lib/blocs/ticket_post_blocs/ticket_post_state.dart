part of 'ticket_post_bloc.dart';

@immutable
abstract class TicketPostState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class TicketPostInitial extends TicketPostState {}

class TicketPostLoading extends TicketPostState {}

class TicketPostLoaded extends TicketPostState {
  final TicketResponse ticket;
  TicketPostLoaded(this.ticket);

  @override
  List<Object?> get props => [ticket];
}

class TicketPostError extends TicketPostState {
  final String message;
  TicketPostError(this.message);

  @override
  List<Object?> get props => [message];
}
