part of 'ticket_state_bloc.dart';

@immutable
abstract class TicketStateState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TicketStateInitial extends TicketStateState {}

class TicketStateLoading extends TicketStateState {}

class TicketStateCreated extends TicketStateState {
  final SimpleDictionaryModel state;
  TicketStateCreated(this.state);

  @override
  List<Object?> get props => [state];
}

class TicketStatesLoaded extends TicketStateState {
  final List<SimpleDictionaryModel> states;
  TicketStatesLoaded(this.states);

  @override
  List<Object?> get props => [states];
}

class TicketStateUpdated extends TicketStateState {
  final SimpleDictionaryModel state;
  TicketStateUpdated(this.state);

  @override
  List<Object?> get props => [state];
}

class TicketStateError extends TicketStateState {
  final String message;
  TicketStateError(this.message);

  @override
  List<Object?> get props => [message];
}
