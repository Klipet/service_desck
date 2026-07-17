part of 'ticket_post_bloc.dart';

@immutable
sealed class TicketPostEvent extends Equatable {
  @override
  List<Object?> get props => [];
}


class TicketFeatEvent extends TicketPostEvent {
  final TicketPostModel getTicket;
  TicketFeatEvent(this.getTicket);

  @override
  List<Object?> get props => [getTicket];
}