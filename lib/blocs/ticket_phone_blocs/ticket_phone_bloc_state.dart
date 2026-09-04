part of 'ticket_phone_bloc_cubit.dart';

@immutable
sealed class TicketPhoneBlocState extends Equatable {
  const TicketPhoneBlocState();

  @override
  List<Object?> get props => [];
}


class TicketPhoneInitial extends TicketPhoneBlocState {
  const TicketPhoneInitial();
}

class TicketPhoneLoading extends TicketPhoneBlocState {
  const TicketPhoneLoading();
}

class TicketPhoneLoaded extends TicketPhoneBlocState {
  final List<TicketPhoneModel> items;

  const TicketPhoneLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class TicketPhoneError extends TicketPhoneBlocState {
  final String message;

  const TicketPhoneError(this.message);

  @override
  List<Object?> get props => [message];
}