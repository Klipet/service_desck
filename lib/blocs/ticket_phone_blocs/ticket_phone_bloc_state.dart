part of 'ticket_phone_bloc_cubit.dart';

@
sealed class TicketPhoneBlocState {
  const TicketPhoneBlocState();

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
}

class TicketPhoneError extends TicketPhoneBlocState {
  final String message;

  const TicketPhoneError(this.message);
}