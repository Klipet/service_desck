part of 'ticket_state_bloc.dart';

@immutable
abstract class TicketStateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateTicketStateEvent extends TicketStateEvent {
  final String apiKey;
  final String name;

  CreateTicketStateEvent({required this.apiKey, required this.name});

  @override
  List<Object?> get props => [apiKey, name];
}

class LoadAllTicketStatesEvent extends TicketStateEvent {
  final String apiKey;
  LoadAllTicketStatesEvent(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class UpdateTicketStateEvent extends TicketStateEvent {
  final String apiKey;
  final SimpleDictionaryModel state;

  UpdateTicketStateEvent({required this.apiKey, required this.state});

  @override
  List<Object?> get props => [apiKey, state];
}
